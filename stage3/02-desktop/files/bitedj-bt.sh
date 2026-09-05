#!/bin/bash
export WAYLAND_DISPLAY=wayland-1
export GTK_CSD=1

# Un-fullscreen Mixxx
export SWAYSOCK=$(ls /run/user/1000/sway-ipc.*.sock | head -n 1)
swaymsg '[app_id="(?i)bitedj"] fullscreen disable' || true

# Start virtual keyboard
/usr/bin/wvkbd-mobintl -L 250 & KBD=$!

blueman-manager &
BM_PID=$!

zenity --info --title="Bluetooth" --text="Tap OK here to close the Bluetooth settings." --width=300

kill -9 $BM_PID
kill -9 $KBD
swaymsg '[app_id="(?i)bitedj"] fullscreen enable'
