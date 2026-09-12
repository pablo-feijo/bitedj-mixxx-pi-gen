# Agent instructions

- Use Conventional Commits. Work on an isolated `codex/<topic>` branch and merge
  into the working semver branch when authorized; do not change another checkout.
- `codex/v0.0.7` is the integration branch. Start follow-up implementation on a
  new feature branch; never commit directly to semver. Use one Conventional Commit via squash merge when
  the user authorizes integration. The initial defaults branch was
  `codex/v007-custom-defaults`.
- Current integration target: `codex/v0.0.7`. Keep `config` IMG_NAME aligned with
  the parent application's BITEDJ_VERSION and update the parent gitlink after
  committing changes here. Publish referenced commits before publishing the parent.
- Install the parent build through `dist-linux`; do not duplicate skins, controller
  mappings or Pad FX presets in this repository. The sample mixxx.cfg is not
  installed; preserve application-managed first-run profile/database creation.
- Update the parent UI position/control guides with UI option changes, including
  the 1024x600 layout check. Keep image docs and defaults in sync with behavior.
- Do not import live machine credentials, VNC settings or board-specific overclock
  changes into generic image defaults. Never flash hardware unless requested.

- The 0.0.7 image historically carried `over_voltage=6`, `arm_freq=2000`, and
  `gpu_freq=750`. Current generic images use firmware clock defaults; apply any
  board-specific tuning explicitly on that device and keep it out of the recipe.

## Git storage, identity and build retention

Follow [Git storage and build retention](docs/GIT_STORAGE.md). Run the staged
1 MiB size guard before each commit; reduce new large assets or keep them
outside Git. Do not configure Git LFS in these forks. Audit and reclaim superseded build outputs before
and after build tasks, preserving current previews and unique data. Verify
canonical author/committer identity; do not generate machine-local email addresses.

## Documentation versus execution records

Keep `/docs/` for concise, reusable human and agent guides. Store roadmaps,
ignored `tasks/<topic>.md` checklists, progress logs and one-off activity reviews under ignored
`/tasks/`; create it locally, never force-add it or link published docs to
local task files. Put durable behavior, testing and attribution facts into
the relevant guide. Keep screenshot captions to one short sentence; link
control mappings and capture provenance rather than repeating them.

During cleanup, remove completed execution plans and activity logs from `tasks/`
after moving durable facts into the relevant guide. Keep active plans and
unresolved backlog items; consolidate outstanding work instead of archiving
finished task folders indefinitely. Never commit `tasks/` or its backups.
