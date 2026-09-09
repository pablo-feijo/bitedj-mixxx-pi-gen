"""Exercise the image capability gate without changing the host clock/boot files."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
GATE = ROOT / 'stage3/02-desktop/files/bitedj-check-system-settings'


class SystemSettingsGateTest(unittest.TestCase):
    def run_gate(self, mode='ok', uid='1000'):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)
            scripts = {
                'id': 'echo "$TEST_UID"',
                'timedatectl': 'exit 0',
                'systemctl': 'exit 0',
                'timeout': 'shift; exec "$@"',
                'sudo': '''
printf '%s\\n' "$*" >> "$TEST_LOG"
[ "$TEST_MODE" != denied ] || { echo 'sudo: a password is required' >&2; exit 1; }
[ "$1" = -n ] || exit 8
shift
if [ "$1" = /usr/bin/bitedj ]; then
    case "$TEST_MODE" in
        missing) echo 'Unknown option' >&2; exit 1 ;;
        crashes) exit 139 ;;
        wrong_status) echo 'Invalid boot-settings request.' >&2; exit 0 ;;
        *) echo 'Invalid boot-settings request.' >&2; exit 1 ;;
    esac
fi
exec "$@"
''',
            }
            for name, contents in scripts.items():
                file = path / name
                file.write_text('#!/bin/sh\n' + contents + '\n')
                file.chmod(0o755)
            log = path / 'calls'
            result = subprocess.run(['sh', str(GATE)], text=True, capture_output=True,
                env={**os.environ, 'PATH': directory + os.pathsep + os.environ['PATH'],
                     'TEST_MODE': mode, 'TEST_UID': uid, 'TEST_LOG': str(log)})
            return result, log.read_text() if log.exists() else ''

    def test_success_is_read_only(self):
        result, calls = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls.splitlines(), ['-n true', '-n timedatectl --version',
            '-n systemctl --version', '-n /usr/bin/bitedj --bitedj-apply-boot-settings'])

    def test_missing_sudo_permission_fails(self):
        result, calls = self.run_gate('denied')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls.splitlines(), ['-n true'])

    def test_old_or_broken_binary_fails(self):
        for mode in ['missing', 'crashes', 'wrong_status']:
            with self.subTest(mode=mode):
                result, _ = self.run_gate(mode)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('helper check failed', result.stderr)

    def test_root_cannot_mask_missing_user_permissions(self):
        result, calls = self.run_gate(uid='0')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, '')


if __name__ == '__main__':
    unittest.main()
