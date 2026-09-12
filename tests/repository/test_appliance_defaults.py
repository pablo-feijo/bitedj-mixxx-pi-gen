"""Contracts for remote recovery and supported touchscreen display profiles."""
from pathlib import Path
import json
import os
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / "config"
CMDLINE = ROOT / "stage1/00-boot-files/files/cmdline.txt"
DESKTOP_RUN = ROOT / "stage3/02-desktop/01-run.sh"
SWAY_CONFIG = ROOT / "stage3/02-desktop/files/i3.conf"
LAUNCHER = ROOT / "stage3/02-desktop/files/sway/scripts/launch-bitedj.sh"
SSH_KEYGEN_UNIT = ROOT / "stage3/02-desktop/files/bitedj-ssh-keygen.service"
SSH_DROP_IN = ROOT / "stage3/02-desktop/files/10-bitedj-host-keys.conf"
SUDOERS = ROOT / "stage3/02-desktop/files/010_pi-nopasswd"
SYSTEM_GATE = ROOT / "stage3/02-desktop/files/bitedj-check-system-settings"


class ApplianceDefaultsTest(unittest.TestCase):
    def test_ssh_is_enabled_and_asserted_during_image_build(self):
        self.assertIn("ENABLE_SSH=1", CONFIG.read_text())
        self.assertIn("PUBKEY_ONLY_SSH=1", CONFIG.read_text())
        self.assertIn("PUBKEY_SSH_FIRST_USER=\"ssh-ed25519 ", CONFIG.read_text())
        stage = DESKTOP_RUN.read_text()
        self.assertIn('touch "${ROOTFS_DIR}/boot/firmware/ssh"', stage)
        self.assertIn("systemctl is-enabled ssh.service", stage)
        self.assertIn("systemctl is-enabled bitedj-ssh-keygen.service", stage)
        self.assertIn("systemctl is-enabled regenerate_ssh_host_keys.service", stage)
        self.assertIn("rm -f \"${ROOTFS_DIR}/etc/ssh/sshd_not_to_be_run\"", stage)
        self.assertIn("ssh-keygen -A", stage)
        self.assertIn("sshd -t", stage)
        self.assertIn("sshd -T | grep -qx 'passwordauthentication no'", stage)
        self.assertIn("systemd-analyze verify bitedj-ssh-keygen.service ssh.service", stage)

    def test_ssh_generates_host_keys_before_daemon_start(self):
        keygen = SSH_KEYGEN_UNIT.read_text()
        drop_in = SSH_DROP_IN.read_text()
        self.assertIn("Before=ssh.service", keygen)
        self.assertIn("ExecStart=/usr/bin/ssh-keygen -A", keygen)
        self.assertIn("Requires=bitedj-ssh-keygen.service", drop_in)
        self.assertIn("After=bitedj-ssh-keygen.service", drop_in)

    def test_desktop_user_has_noninteractive_systemctl_capability(self):
        self.assertEqual(SUDOERS.read_text().strip(), "pi ALL=(ALL) NOPASSWD: ALL")
        gate = SYSTEM_GATE.read_text()
        self.assertIn("sudo -n true", gate)
        self.assertIn("sudo -n systemctl --version", gate)

    def test_hdmi_and_touch_display_2_are_landscape(self):
        sway = SWAY_CONFIG.read_text()
        self.assertIn("output HDMI-A-1 disable", sway)
        self.assertIn("output DSI-1 mode 720x1280 transform 90", sway)
        self.assertIn("output DSI-2 mode 720x1280 transform 90", sway)
        cmdline = CMDLINE.read_text()
        self.assertIn("video=DSI-1:720x1280@60,rotate=90", cmdline)
        self.assertIn("video=DSI-2:720x1280@60,rotate=90", cmdline)

    def test_kiosk_workspace_prefers_dsi_and_starts_focused(self):
        sway = SWAY_CONFIG.read_text()
        self.assertIn("workspace 1 output DSI-1 DSI-2 HDMI-A-1", sway)
        launcher = LAUNCHER.read_text()
        self.assertIn('"$SWAYMSG" -- workspace number 1', launcher)
        self.assertLess(launcher.index('"$SWAYMSG" -- workspace number 1'),
                        launcher.index("exec env"))

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
            app.write_text(
                "#!/bin/sh\n"
                "printf 'app scale=%s %s\\n' \"${QT_SCALE_FACTOR:-}\" \"$*\" >> \"$TEST_CALLS\"\n"
            )
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
        self.assertEqual(calls[:4], [
            "-- output HDMI-A-1 disable",
            "-- output DSI-2 enable mode 720x1280",
            "-- input type:touch map_to_output DSI-2",
            "-- workspace number 1",
        ])
        self.assertTrue(calls[4].startswith("app scale=1.20 --resourcePath"))

    def test_launcher_keeps_hdmi_profile_without_dsi(self):
        result, calls = self.run_launcher([
            {"name": "HDMI-A-1", "active": True},
        ])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[:3], [
            "-- output HDMI-A-1 enable mode --custom 1024x600",
            "-- input type:touch map_to_output HDMI-A-1",
            "-- workspace number 1",
        ])
        self.assertTrue(calls[3].startswith("app scale=1.00 --resourcePath"))

    def test_manual_launchers_reuse_the_display_profile(self):
        for relative in (
            "stage3/02-desktop/files/waybar/mixxx.sh",
            "stage3/02-desktop/files/i3blocks/scripts/mixxx.sh",
        ):
            launcher = (ROOT / relative).read_text()
            self.assertIn("/home/pi/.config/sway/scripts/launch-bitedj.sh", launcher)
            self.assertNotIn("/usr/bin/bitedj --resourcePath", launcher)


if __name__ == "__main__":
    unittest.main()
