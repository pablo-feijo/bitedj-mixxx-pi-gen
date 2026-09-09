# Custom Bite DJ OS Image Generator (mixxx-pi-gen)

This repository generates a customized Raspberry Pi OS image (Debian 13 "Trixie" based) tailored for **BiteDJ**, a DJ appliance fork of Mixxx. 
This is a fork of the excellent [fayaaz/mixxx-pi-gen](https://github.com/fayaaz/mixxx-pi-gen).

Start DJing in minutes with a Raspberry Pi, a touchscreen, and a DJ controller!

## Working version 0.0.7

`codex/v0.0.7` is the working integration branch, producing
`bitedj-pi-v0.0.7`. Its Custom Bite DJ defaults were integrated from
`codex/v007-custom-defaults` with a merge commit. Start future work on a new
feature branch and merge back only when authorized.
The parent Custom Bite DJ repository pins the exact commit via its submodule.
Build the parent application's matching ARM64 version before creating an image;
`dist-linux` supplies the binary, current skin, controller mappings and resources.
That includes the two-deck layout, compact General settings, PAD FX as the third
Settings tab, system-owned Pad FX presets, Rekordbox waveforms/optional phrases,
colored cue previews, the Prepare queue and optional return to Play. No skin
copies belong here. See [CHANGELOG.md](CHANGELOG.md) for image changes.

`stage3/02-desktop/files/mixxx.cfg` is a reference profile, not an installed
first-boot config: the existing installer deliberately leaves profile creation
to the application. Its compact library, BiteDJ skin and safe loading values
are kept current without importing developer VNC or device-specific settings.
Sustained virtual-device audio validation remains open in the parent repository.
This working version is not a published image or a hardware validation claim.

Thanks to Team Deckshark, Mixxx, fayaaz/mixxx-pi-gen and their contributors for
the foundation, and xsploit/bitedj for the adapted application improvements.

## Features Included
- Pre-built **BiteDJ** installed directly into the image.
- 64-bit Raspberry Pi OS (Debian 13 "Trixie").
- `preempt=full` commandline argument on the standard kernel and performance CPU governor.
- `sway` (i3 for Wayland) window manager with autostart straight into BiteDJ.
- Working OpenGL waveforms.
- Custom touch-optimized skin built into BiteDJ (`BiteDJ` skin).
- Waybar with useful system indicators.

## How to Build the Image

The build system relies on Docker and expects the pre-compiled BiteDJ Linux binaries to be available.

### Prerequisites

1. **Clone BiteDJ and this repository**:
   This repository is typically included as a submodule of the main `custom-bitedj` repository.
   ```bash
   git clone --recurse-submodules https://github.com/pablo-feijo/custom-bitedj.git
   cd custom-bitedj
   ```

2. **Build BiteDJ**:
   You must compile BiteDJ first so that the build artifacts are available in the `dist-linux/` directory.
   (Follow the build instructions in the main BiteDJ repository).

3. **Build the OS Image**:
   Once `dist-linux/bin/mixxx` is successfully created by BiteDJ, you can generate the Pi OS image:
   ```bash
   cd mixxx-pi-gen
   ./build-docker.sh
   ```

The resulting `.img` or `.zip` will be output into `mixxx-pi-gen/deploy/`.

## How to install on your Raspberry Pi 3/4/400/5

Flash the generated image from the `deploy/` folder to your SD card using tools like **Raspberry Pi Imager** or **BalenaEtcher**.

### Default Credentials
- **Username**: `pi`
- **Password**: `bitedj`
- **Home directory**: `/home/pi/`

## Troubleshooting and Debugging

- **Terminal access**: Plugging in a keyboard and hitting `super+enter` will give you a terminal over the UI.
- **Logs**: Logs for BiteDJ are available at `/home/pi/.mixxx/mixxx.log` (Mixxx config path is preserved for compatibility).

---
*Original instructions of the forked pi-gen repository are in [pi-gen-readme.md](pi-gen-readme.md)*
