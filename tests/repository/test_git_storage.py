#!/usr/bin/env python3
"""Exercise the guard against real Git indexes and LFS clean filters."""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[2] / "scripts/test/check-git-storage.py"

class StoragePolicyTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git("init", "-q")
        self.script = self.root / "scripts/test/check-git-storage.py"
        self.script.parent.mkdir(parents=True)
        shutil.copyfile(SOURCE, self.script)

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.root), *args], stderr=subprocess.STDOUT)

    def check(self, success):
        result = subprocess.run([sys.executable, str(self.script)], cwd="/", capture_output=True, text=True)
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)

    def test_small_file_with_spaces(self):
        (self.root / "small file").write_text("source")
        self.git("add", "small file")
        self.check(True)

    def test_staged_large_blob_cannot_hide_behind_small_working_file(self):
        p = self.root / "large.bin"
        p.write_bytes(b"x" * (1048576 + 1))
        self.git("add", "large.bin")
        p.write_text("small now")
        self.check(False)

    def test_size_boundary(self):
        p = self.root / "fixture.bin"
        p.write_bytes(b"x" * 1048576)
        self.git("add", "fixture.bin")
        self.check(True)
        p.write_bytes(b"x" * (1048576 + 1))
        self.git("add", "fixture.bin")
        self.check(False)

    def test_generated_output_even_when_small(self):
        p = self.root / "deploy/image.img"
        p.parent.mkdir()
        p.write_text("generated")
        self.git("add", "deploy/image.img")
        self.check(False)

    def test_force_added_local_task_is_rejected(self):
        p = self.root / "tasks/roadmap.md"
        p.parent.mkdir()
        p.write_text("local execution log")
        self.git("add", "tasks/roadmap.md")
        self.check(False)

    def test_lfs_clean_filter_and_unfiltered_content(self):
        self.git("lfs", "install", "--local")
        self.git("lfs", "track", "asset.bin")
        p = self.root / "asset.bin"
        p.write_bytes(b"x" * (1048576 + 1))
        self.git("add", ".gitattributes", "asset.bin")
        self.check(True)
        oid = self.git("hash-object", "-w", "--no-filters", "asset.bin").decode().strip()
        self.git("update-index", "--cacheinfo", "100644", oid, "asset.bin")
        self.check(False)

if __name__ == "__main__":
    unittest.main()
