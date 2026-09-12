# Changelog

## [Unreleased]

### Changed

- Keep generic Pi 4 and Pi 5 images on firmware clock defaults.
- Add pre-rotated Plymouth plumbing for Touch Display 2 while documenting that
  the physical portrait-cropping issue remains unresolved.
- Disable the fixed firmware-level splash so it cannot appear vertically before
  the adaptive Plymouth theme on Touch Display 2.
- Keep DSI in its native portrait mode during kernel/Plymouth startup; Sway owns
  the later 90-degree landscape transform for the application session. This did
  not by itself correct the physical boot splash.

## [0.0.7] — 2026-09-09

### Changed

- Build the matching ARM64 application before CI image generation, verify the archive and retain source provenance.
- Include the user-approved boot overrides: `over_voltage=6`, `arm_freq=2000`,
  and `gpu_freq=750`. The local library visibility and 22px row-height changes
  are retained in the reference profile.

- Align the working image name with Custom Bite DJ 0.0.7 (`bitedj-pi-v0.0.7`).
- Document the parent repository as the source of the application, skin,
  controller mappings and system-owned Pad FX presets through `dist-linux`.
- Refresh the reference profile for the BiteDJ skin, compact library layout
  and safe loading. The installer still lets the application create its own
  first-run profile; the reference profile is not installed automatically.
- Support Debian 13 Trixie dependencies and verify Qt application versions
  without requiring an interactive desktop.

### Documentation

- Use isolated feature branches and Conventional Commits; synchronize the
  parent gitlink after image-generator changes.
- Credit fayaaz/mixxx-pi-gen, Team Deckshark, Mixxx and xsploit for their work.
- Record source/version provenance and keep generated images and test output
  outside Git.
