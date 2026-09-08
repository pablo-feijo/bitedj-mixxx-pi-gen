# Changelog

## [v0.0.6] - 2026-09-08

### Features
- add default output transform 0 for rotation persistence (872cf0d)
- add 'Forget a Device' option to Bluetooth UI and finalize disconnect logic (09841a9)
- implement custom touch-friendly Zenity Wi-Fi connection manager (9d497ac)
- add disconnect button to bluetooth window (c3dfcef)
- add Bluetooth Headphones ALSA alias for mixxx (c937007)
- build native GTK zenity wrapper for wifi selection (f6ba76d)
- add pipewire bluetooth and bluez tools for wireless audio support (1034700)
- add blueman for bluetooth gui management (212e4fb)
- add systemd oneshot service to auto-expand rootfs on first boot (95478f9)

### Bug Fixes
- enable software cursors and set seat cursor theme for rotated displays (b044343)
- remove literal quotes from sway workspace name to prevent dual-desktop spawn bug (6689197)
- remove hardware flag to prevent Raspberry Pi VCHI kernel panic on bcm2835 driver (d44faf4)
- restore PA_ALSA_PLUGHW=1 to fix PortAudio buffer underruns when routing to PipeWire (9d39a41)
- strip restrictive PortAudio hardware flag now that C++ whitelist correctly parses sysdefault aliases for physical controllers (958ba54)
- restore PA_ALSA_PLUGHW environment variable to expose raw hardware ALSA nodes to Mixxx (65a071d)
- migrate wireplumber config to 0.5 SPA-JSON format to correctly ignore DDJ-400 (4b1e945)
- inject PIPEWIRE_LATENCY to fix portaudio alsa buffer underruns (d0c813f)
- remove aggressive A2DP force rule that crashed bluetoothd (2f9986b)
- force high-fidelity A2DP over bluetooth and disable idle suspend drops (a8b05ed)
- unmask pipewire for bluetooth audio and configure wireplumber to ignore the DDJ-400 for raw ALSA exclusivity (c683ef8)
- remove invalid keyboard flag and add universal close buttons (e126867)
- disable nm-applet and wifi popups to ensure clean kiosk mode (03878e1)
- explicitly focus BiteDJ workspace on boot to prevent default blank space (2e6227a)
-  Waybar/i3blocks launch script to use correct environment variables (ad8d70c)
-  preferences dialog cropping via absolute bounds (ddd1dc5)
-  pioneer splash image (653bc51)

### Styling
- remove virtual keyboard from bluetooth menu (fc176af)
- replace bulky zenity close button with native swaynag bar and fix fullscreen selector (400bcf1)
- shrink virtual keyboard height and move bluetooth close button to top left corner (80d28e6)

### Documentation
- add CHANGELOG.md and reference it in README (f67477c)
- Update README for BiteDJ (7443e80)
- move BiteDJ Networking Audio docs to parent repository root (f6db879)
- rewrite networking and audio architecture docs to formally detail the v0.0.5 PipeWire c++ fix, kernel panic resolution, and sway ghost desktop bug (af112de)
- add comprehensive networking and audio infrastructure documentation (88e567a)
- Update desktop wallpaper to use minimalist pioneer boot image (32e43f8)
- Update OS config for BiteDJ (3e76ab0)

### Chores & Maintenance
- bump semver to v0.0.6 in OS image configuration (1daa3d9)
- bump semver to v0.0.5 in OS image configuration (b9d8800)
- OS: Upgrade base OS from Debian Bookworm to Debian Trixie to support newer compiled bitedj binary (FFmpeg 7, GLIBC 2.38) (e4544ff)
- OS: Disable toxic apt autoremove that accidentally purged lightdm, waybar, and critical UI packages at the end of the build (ac440aa)
- OS: Add missing xserver-xorg required by LightDM, and swaybg to perfectly mirror working Pi (f1848a8)
- OS: Revert to LightDM architecture since pure terminal autostart failed (7360be9)
- OS: Ditch LightDM completely, use B2 console autologin with bash_profile exec sway (b56a2e1)
- OS: Re-remove deprecated Bullseye packages (rpi-swap, rpi-usb-gadget) that break Bookworm builds (31c5d2d)
- OS: Explicitly enable LightDM service and install wayvnc for testing (85628cf)
- Revert OS package optimizations to restore working boot state (4e278f6)
- OS: Fix LightDM crashing by installing lightdm-gtk-greeter since pi-greeter is purged (0eccdde)
- OS: Fix broken script terminations by supplying missing autologin.conf and fixing lightdm directory creation (5b35f89)
- OS: Fix build failure by re-disabling rpi-resize (deprecated in Bookworm) (0963039)
- OS: Re-enable rpi-resize for first-boot partition expansion (cf7da5c)
- OS: Install early firmware boot splash image (splash.png) to /boot/firmware (53401ff)
- OS: Add udev rules for DDJ-400, optimize packages (remove swap, gadget, resize) (60b258e)
- Add max_usb_current=1 to config.txt for DDJ-400 power (5136591)
- Disable toxic auto_exit_fullscreen script that breaks Qt layouts (cff93d0)
- Remove floating disable for Mixxx dialogs to fix Qt layout bugs (136b275)
- Explicitly disable floating for dialogs (a411874)
- Use native fullscreen enable for all Mixxx dialogs (c8041cc)
- Force Mixxx dialogs to display fullscreen (204f8d8)
- Ensure desktop wallpaper exactly matches the latest boot splash image (18c537d)
- Remove --safe-mode from autostart (66c68da)
- Allow pi user passwordless udisks2 operations for USB eject (1aee9e9)

### Build System
- append v0.0.4 semver to IMG_NAME output (3664169)


---
*This changelog was generated based on Conventional Commits.*
