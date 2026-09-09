# Changelog

## [0.0.7] — Unreleased

### Changed

- Include the user-approved boot overrides: `over_voltage=6`, `arm_freq=2000`,
  and `gpu_freq=750`. The local library visibility and 22px row-height changes
  are retained in the reference profile.

- Align the working image name with Custom Bite DJ 0.0.7 (`bitedj-pi-v0.0.7`).
- Document the parent repository as the source of the application, skin,
  controller mappings and system-owned Pad FX presets through `dist-linux`.
- Refresh the reference profile for the BiteDJ skin, compact library layout
  and safe loading. The installer still lets the application create its own
  first-run profile; the reference profile is not installed automatically.
- Integrate `codex/v007-custom-defaults` into `codex/v0.0.7` with a merge commit.

### Documentation

- Use isolated feature branches and Conventional Commits; synchronize the
  parent gitlink after image-generator changes.
- Credit fayaaz/mixxx-pi-gen, Team Deckshark, Mixxx and xsploit for their work.
- No image build, flash or release tag is included. Sustained audio and hardware
  checks remain separate validation steps; generated test results are not tracked.
