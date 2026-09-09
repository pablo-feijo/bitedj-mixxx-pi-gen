# Git storage and build retention

Keep source, generators and small curated assets in Git. New or changed ordinary
Git blobs must be at most **1 MiB**. Store an indispensable larger binary asset
through Git LFS; generated builds, OS images, archives, test recordings, logs and
caches belong in ignored runtime directories or release/artifact storage, never
in Git or LFS. Optimize documentation screenshots before committing them.

Run `python3 scripts/test/check-git-storage.py` after staging and before committing.
CI checks the complete index, so staged oversized content is caught even if the
working file was subsequently shrunk. There are no large-blob exemptions.
LFS-tracked files must be canonical pointers in the index; keep their hydrated
content available for builds and tests.

## Git LFS

GitHub currently rejects new LFS uploads to these public forks unless their
upstream network already uses LFS or the uploader can write upstream. See
[GitHub’s fork rules](https://docs.github.com/en/repositories/working-with-files/managing-large-files/collaboration-with-git-large-file-storage).
Existing inherited parent fixtures retain exact path/blob exemptions. Do not
add new exemptions: confirm that an approved LFS endpoint accepts uploads
before converting another asset, and never publish unresolved pointers.

Install Git LFS, then initialize each repository separately:

```sh
git lfs install --local
git lfs track 'path/to/required-large-asset.bin'
git add .gitattributes path/to/required-large-asset.bin
git lfs ls-files
git lfs fsck
python3 scripts/test/check-git-storage.py
```

Use exact paths or narrowly scoped patterns, never blanket image/audio patterns
that migrate upstream fixtures accidentally. Commit `.gitattributes` with the
pointer; ensure `git show :path/to/required-large-asset.bin` is an LFS pointer.
Upload LFS objects before publishing refs (`git lfs push --all origin <branch>`)
and validate a fresh clone with `git lfs pull` and `git lfs fsck`. CI checkouts
must enable `lfs: true`. Recursive submodule checkouts need LFS initialized and
pulled inside the submodule as well. Build containers consume hydrated host assets;
never package an unresolved pointer. Track source URLs/licenses for external assets.

LFS tracking only affects newly staged content. Migrating existing history is a
separate, explicitly authorized rewrite: audit paths and refs, retain recovery
refs, validate contents and remap dependent submodule gitlinks. Publish rewritten
submodule commits first and use explicit expected-value force-with-lease for each
changed ref. Preserve upstream author credits, upstream tags and unrelated history.
Old objects stay on disk while any branch, tag, recovery ref or reflog retains
them; LFS migration alone does not reclaim ignored build directories.

## Reclaim past build space on every build task

Before a large build and after successful validation, inventory host usage,
worktree outputs and Docker bind mounts. Keep the current validated build/preview,
active builds, unique settings/media, and explicitly requested release artifacts.
Remove superseded reproducible build/install directories, temporary staging,
raw test captures and obsolete image/archive copies once ownership and inactivity
are established. Do not retain a second raw OS image when its required validated
archive suffices. Do not delete the last useful build before its replacement passes.

Record exact removed paths and reclaimed bytes in ignored `test-results/` (pi-gen
may use its ignored `work/`). An old timestamp alone does not prove inactivity.
Keep brief provenance and unique recovery data; do not archive reproducible caches
under new backup folders. Preserve named compiler caches and healthy running
containers. Use scoped cleanup by default; global Docker pruning requires explicit
scope. Aim for at least 10 GiB free before heavy builds. Report retained large
folders with a reason and next cleanup action.

## Commit identity

Use the configured project identity and verify it with `git var GIT_AUTHOR_IDENT`
and `git var GIT_COMMITTER_IDENT` before committing. For this fork the canonical
identity is `Pablo Feijo <devpablofeijo@gmail.com>`. Set repository-local `user.name`,
`user.email` and `user.useConfigOnly=true`; do not rely on machine-derived emails.
Keep upstream authors and coauthor trailers accurate. A `.mailmap` fixes display
only; actual historical corrections require an authorized history rewrite.

## Documentation placement

`docs/` contains reusable human and agent guides. Local roadmaps, task plans
and execution logs live in ignored `/tasks/`, never Git or LFS. Do not link
published guides to local-only files. Use short screenshot captions and link
to canonical control mappings/provenance.

During cleanup, remove completed execution plans and activity logs from `tasks/`
after moving durable facts into the relevant guide. Keep active plans and
unresolved backlog items; consolidate outstanding work instead of archiving
finished task folders indefinitely. Never commit `tasks/` or its backups.
