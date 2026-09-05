#!/bin/bash
export WAYLAND_DISPLAY=wayland-1
export GTK_CSD=1

# Un-fullscreen Mixxx
export SWAYSOCK=$(ls /run/user/1000/sway-ipc.*.sock | head -n 1)
swaymsg '[app_id="(?i)bitedj"] fullscreen disable' || true

# Start virtual keyboard
/usr/bin/wvkbd-mobintl -L 250 -b & KBD=$!

zenity --info --text="Scanning for Wi-Fi networks..." --timeout=2 --no-wrap &
nmcli dev wifi rescan
sleep 2

# Get available networks (SSID | Security | Signal)
NETWORKS=$(nmcli -t -f SSID,SECURITY,SIGNAL dev wifi | awk -F: '$1 != "" {print $1 "\n" $2 "\n" $3 "%"}')

if [ -z "$NETWORKS" ]; then
    zenity --error --text="No Wi-Fi networks found."
    kill -9 $KBD
    swaymsg '[app_id="(?i)bitedj"] fullscreen enable'
    exit 1
fi

# Show list dialog
SELECTION=$(echo "$NETWORKS" | zenity --list --title="Wi-Fi Networks" --text="Select a network to connect:" --column="SSID" --column="Security" --column="Signal" --width=600 --height=400)

if [ -z "$SELECTION" ]; then
    kill -9 $KBD
    swaymsg '[app_id="(?i)bitedj"] fullscreen enable'
    exit 0
fi

# Ask for password
PASSWORD=$(zenity --password --title="Wi-Fi Password" --text="Enter password for $SELECTION:")
if [ -n "$PASSWORD" ]; then
    if nmcli dev wifi connect "$SELECTION" password "$PASSWORD"; then
        zenity --info --text="Successfully connected to $SELECTION!" --timeout=3
    else
        zenity --error --text="Failed to connect to $SELECTION."
    fi
fi

kill -9 $KBD
swaymsg '[app_id="(?i)bitedj"] fullscreen enable'
