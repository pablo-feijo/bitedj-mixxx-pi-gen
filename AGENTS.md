# Agent instructions

- Use Conventional Commits. Work on an isolated `codex/<topic>` branch and merge
  into the working semver branch when authorized; do not change another checkout.
- `codex/v0.0.7` is the integration branch. Start follow-up implementation on a
  new feature branch; never commit directly to semver. Use merge commits when
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
