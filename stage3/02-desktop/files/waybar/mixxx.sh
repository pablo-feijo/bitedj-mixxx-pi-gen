#!/bin/bash

if ! pgrep -x "bitedj" > /dev/null && ! pgrep -x "mixxx" > /dev/null
then
    swaymsg exec "/home/pi/.config/sway/scripts/launch-bitedj.sh"
fi
