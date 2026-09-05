#!/bin/bash
export WAYLAND_DISPLAY=wayland-1
export GTK_CSD=1

# Un-fullscreen Mixxx
export SWAYSOCK=$(ls /run/user/1000/sway-ipc.*.sock | head -n 1)
swaymsg '[app_id="(?i)bitedj"] fullscreen disable' || true

# Start virtual keyboard smaller
/usr/bin/wvkbd-mobintl -L 100 & KBD=$!

blueman-manager &
BM_PID=$!

zenity --info --title="Bluetooth" --text="Tap OK here to close the Bluetooth settings." --width=250 --height=50 &
ZEN_PID=$!

# Wait for window to appear and move it
for i in {1..20}; do
  if swaymsg '[title="Bluetooth"] move position 0 0' >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

wait $ZEN_PID

kill -9 $BM_PID
kill -9 $KBD
swaymsg '[app_id="(?i)bitedj"] fullscreen enable'
