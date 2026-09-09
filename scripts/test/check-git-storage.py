#!/usr/bin/env python3
"""Check the complete Git index, not unstaged working-copy files."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
LIMIT = 1024 * 1024

def git(*args, data=None):
    return subprocess.check_output(["git", "-C", str(ROOT), *args], input=data)

def main():
    entries = []
    errors = []
    for record in git("ls-files", "--stage", "-z").split(b"\0"):
        if not record:
            continue
        meta, path = record.split(b"\t", 1)
        mode, oid, stage = meta.split()
        name = path.decode("utf-8", "surrogateescape")
        if stage != b"0":
            errors.append(f"{name}: resolve the index conflict before checking")
        elif mode != b"160000":
            entries.append((name, oid.decode()))
    attrs = git("check-attr", "--cached", "-z", "--stdin", "filter",
                data=b"".join(name.encode("utf-8", "surrogateescape") + b"\0" for name, _ in entries)).split(b"\0")
    lfs_paths = {attrs[i].decode("utf-8", "surrogateescape")
                 for i in range(0, len(attrs) - 1, 3) if attrs[i + 2] == b"lfs"}
    sizes = git("cat-file", "--batch-check=%(objectname) %(objecttype) %(objectsize)",
                data="".join(oid + "\n" for _, oid in entries).encode()).splitlines()
    for (name, oid), result in zip(entries, sizes, strict=True):
        _, kind, size = result.split()
        if kind != b"blob":
            errors.append(f"{name}: expected a blob")
            continue
        if name in lfs_paths:
            pointer = git("cat-file", "blob", oid) if int(size) < 1024 else b""
            checked = subprocess.run(["git", "-C", str(ROOT), "lfs", "pointer", "--check", "--strict", "--stdin"],
                                     input=pointer, capture_output=True)
            if checked.returncode:
                errors.append(f"{name}: LFS-tracked content is not a canonical LFS pointer")
        first, sep, _ = name.partition("/")
        generated = sep and (first in {"test-results", "test-config", "test-music", "deploy", "work", "tasks"}
                            or first.startswith(("build-", "dist-linux")))
        if generated:
            errors.append(f"{name}: generated output belongs outside Git and LFS")
        if int(size) > LIMIT:
            errors.append(f"{name}: {int(size):,} bytes; remove generated output or use Git LFS")
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Git storage check passed ({len(entries)} indexed files; 1 MiB limit).")
    return 0

if __name__ == "__main__":
    sys.exit(main())
