# BiteDJ OS Image Generator (mixxx-pi-gen)

This repository generates a customized Raspberry Pi OS image (Debian 13 "Trixie" based) tailored for **BiteDJ**, a DJ appliance fork of Mixxx. 
This is a fork of the excellent [fayaaz/mixxx-pi-gen](https://github.com/fayaaz/mixxx-pi-gen).

Start DJing in minutes with a Raspberry Pi, a touchscreen, and a DJ controller!

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
- **Password**: `mixxx`
- **Home directory**: `/home/pi/`

## Troubleshooting and Debugging

- **Terminal access**: Plugging in a keyboard and hitting `super+enter` will give you a terminal over the UI.
- **Logs**: Logs for BiteDJ are available at `/home/pi/.mixxx/mixxx.log` (Mixxx config path is preserved for compatibility).

---
*Original instructions of the forked pi-gen repository are in [pi-gen-readme.md](pi-gen-readme.md)*
