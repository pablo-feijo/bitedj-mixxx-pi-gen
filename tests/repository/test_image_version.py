#!/usr/bin/env python3
"""Exercise image metadata against the installed application's CLI output."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / 'stage3/01-install-packages/01-run.sh'
VERSION = '0.0.7-codex-pi-semver-deploy.6'

class ImageVersionTest(unittest.TestCase):
    def run_install(self, output, success):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            binary = base / 'dist-linux/bin/mixxx'
            binary.parent.mkdir(parents=True)
            binary.write_text('fixture')
            root = base / 'rootfs'
            root.mkdir()
            env = dict(os.environ, BASE_DIR=str(base), ROOTFS_DIR=str(root),
                       IMG_NAME='bitedj-pi-v' + VERSION, CLI_OUTPUT=output,
                       SCRIPT=str(SCRIPT))
            result = subprocess.run(['bash', '-c',
                'on_chroot() { printf "%s" "$CLI_OUTPUT"; }; '
                'export -f on_chroot; bash "$SCRIPT"'], env=env,
                capture_output=True, text=True)
            self.assertEqual(result.returncode == 0, success, result.stderr)
            if success:
                self.assertEqual((root / 'opt/bitedj.version').read_text(), VERSION + '\n')
                self.assertEqual((root / 'opt/mixxx.version').read_text(), VERSION + '\n')
                self.assertEqual((root / 'opt/mixxx.tag').read_text(), 'v' + VERSION + '\n')
            else:
                self.assertFalse((root / 'opt/bitedj.version').exists())

    def test_qt_version_with_leading_blank_line(self):
        self.run_install('\nBite DJ ' + VERSION + '\n', True)

    def test_different_binary_version(self):
        self.run_install('\nBite DJ 1.0\n', False)

    def test_missing_version(self):
        self.run_install('', False)

if __name__ == '__main__':
    unittest.main()
