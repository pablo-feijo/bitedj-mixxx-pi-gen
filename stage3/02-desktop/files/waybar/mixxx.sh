#!/bin/bash

if ! pgrep -x "bitedj" > /dev/null && ! pgrep -x "mixxx" > /dev/null
then
    if [ -x "/usr/bin/bitedj" ]; then
        swaymsg exec "/usr/bin/bitedj"
    else
        swaymsg exec "/usr/bin/mixxx"
    fi
fi
