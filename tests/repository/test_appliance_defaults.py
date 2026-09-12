"""Contracts for remote recovery and supported touchscreen display profiles."""
from pathlib import Path
import json
import os
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / "config"
DESKTOP_RUN = ROOT / "stage3/02-desktop/01-run.sh"
SWAY_CONFIG = ROOT / "stage3/02-desktop/files/i3.conf"
LAUNCHER = ROOT / "stage3/02-desktop/files/sway/scripts/launch-bitedj.sh"


class ApplianceDefaultsTest(unittest.TestCase):
    def test_ssh_is_enabled_and_asserted_during_image_build(self):
        self.assertIn("ENABLE_SSH=1", CONFIG.read_text())
        stage = DESKTOP_RUN.read_text()
        self.assertIn('touch "${ROOTFS_DIR}/boot/firmware/ssh"', stage)
        self.assertIn("systemctl is-enabled ssh.service", stage)
        self.assertIn("systemctl is-enabled regenerate_ssh_host_keys.service", stage)

    def test_hdmi_and_touch_display_2_are_landscape(self):
        sway = SWAY_CONFIG.read_text()
        self.assertIn("output HDMI-A-1 mode --custom 1024x600 transform 0", sway)
        self.assertIn("output DSI-1 mode 720x1280 transform 90", sway)
        self.assertIn("output DSI-2 mode 720x1280 transform 90", sway)

    def test_launcher_prefers_dsi_and_maps_touch_to_selected_output(self):
        launcher = LAUNCHER.read_text()
        self.assertIn('"$SWAYMSG" -- output HDMI-A-1 disable', launcher)
        self.assertIn('"$SWAYMSG" -- input type:touch map_to_output "$dsi_output"', launcher)
        self.assertIn('"$SWAYMSG" -- input type:touch map_to_output HDMI-A-1', launcher)
        self.assertLess(launcher.index('"$SWAYMSG" -- input'), launcher.index("exec env"))

    def run_launcher(self, outputs):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            calls = base / "calls"
            swaymsg = base / "swaymsg"
            swaymsg.write_text(
                "#!/bin/sh\n"
                "if [ \"$*\" = '-r -t get_outputs' ]; then\n"
                "  printf '%s\\n' \"$TEST_OUTPUTS\"\n"
                "else\n"
                "  printf '%s\\n' \"$*\" >> \"$TEST_CALLS\"\n"
                "fi\n"
            )
            swaymsg.chmod(0o755)
            app = base / "bitedj"
            app.write_text("#!/bin/sh\nprintf 'app %s\\n' \"$*\" >> \"$TEST_CALLS\"\n")
            app.chmod(0o755)
            result = subprocess.run(
                ["sh", str(LAUNCHER)],
                text=True,
                capture_output=True,
                env={
                    **os.environ,
                    "BITEDJ_SWAYMSG": str(swaymsg),
                    "BITEDJ_EXECUTABLE": str(app),
                    "TEST_OUTPUTS": json.dumps(outputs),
                    "TEST_CALLS": str(calls),
                },
            )
            return result, calls.read_text().splitlines()

    def test_launcher_selects_dsi2_before_starting_app(self):
        result, calls = self.run_launcher([
            {"name": "HDMI-A-1", "active": True},
            {"name": "DSI-2", "active": True},
        ])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[:3], [
            "-- output HDMI-A-1 disable",
            "-- output DSI-2 enable mode 720x1280",
            "-- input type:touch map_to_output DSI-2",
        ])
        self.assertTrue(calls[3].startswith("app --resourcePath"))

    def test_launcher_keeps_hdmi_profile_without_dsi(self):
        result, calls = self.run_launcher([
            {"name": "HDMI-A-1", "active": True},
        ])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[:2], [
            "-- output HDMI-A-1 enable mode --custom 1024x600",
            "-- input type:touch map_to_output HDMI-A-1",
        ])
        self.assertTrue(calls[2].startswith("app --resourcePath"))


if __name__ == "__main__":
    unittest.main()
