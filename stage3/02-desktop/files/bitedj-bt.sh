#!/bin/bash
pgrep -x "zenity" > /dev/null && exit 0
pgrep -x "blueman-manager" > /dev/null && exit 0

export WAYLAND_DISPLAY=wayland-1
export GTK_CSD=1
export SWAYSOCK=$(ls -t /run/user/1000/sway-ipc.*.sock | head -n 1)

swaymsg "fullscreen disable"

# Get paired devices
DEVICES=$(bluetoothctl devices Paired | sed 's/Device //g' | awk '{MAC=$1; $1=""; print MAC "\n" $0}')

SELECTION=$(echo -e "DISCONNECT\n[Disconnect Current Device]\nPAIR_NEW\n[Pair New Device...]\n$DEVICES" | zenity --list --title="Bluetooth" --text="Tap an option below:" --column="MAC" --column="Name" --hide-column=1 --width=600 --height=400)

if [ "$SELECTION" == "PAIR_NEW" ]; then
    blueman-manager &
    swaynag -t warning -m "Bluetooth Manager" -B "Close" "pkill -9 -f blueman; killall swaynag" &
    NAG_PID=$!
    wait $NAG_PID
    pkill -9 -f blueman 2>/dev/null
    killall swaynag 2>/dev/null
elif [ "$SELECTION" == "DISCONNECT" ]; then
    zenity --info --text="Disconnecting audio..." --timeout=1 --no-wrap &
    for mac in $(bluetoothctl info | grep "Device" | awk '{print $2}'); do
        bluetoothctl disconnect "$mac"
    done
elif [ -n "$SELECTION" ]; then
    zenity --info --text="Connecting to audio..." --timeout=2 --no-wrap &
    bluetoothctl disconnect "$SELECTION" 2>/dev/null
    sleep 1
    bluetoothctl connect "$SELECTION"
    sleep 2
fi

swaymsg "fullscreen enable"
