#!/bin/bash
pgrep -x "blueman-manager" > /dev/null && exit 0
pgrep -x "swaynag" > /dev/null && exit 0
export WAYLAND_DISPLAY=wayland-1
export GTK_CSD=1

# Un-fullscreen Mixxx
export SWAYSOCK=$(ls -t /run/user/1000/sway-ipc.*.sock | head -n 1)
swaymsg "fullscreen disable"

# Start virtual keyboard smaller
/usr/bin/wvkbd-mobintl -L 100 & KBD=$!

blueman-manager &

swaynag -t warning -m "Bluetooth Settings" -B "Close" "pkill -9 -f blueman; killall swaynag" &
NAG_PID=$!

wait $NAG_PID

kill -9 $KBD 2>/dev/null
pkill -9 -f blueman 2>/dev/null
killall swaynag 2>/dev/null
swaymsg "fullscreen enable"
