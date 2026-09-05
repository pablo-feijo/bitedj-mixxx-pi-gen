#!/bin/bash

if ! pgrep -x "bitedj" > /dev/null && ! pgrep -x "mixxx" > /dev/null
then
    if [ -x "/usr/bin/bitedj" ]; then
        swaymsg exec "env PA_ALSA_PLUGHW=1 WLR_DRM_NO_MODIFIERS=1 QT_WAYLAND_SHELL_INTEGRATION=xdg-shell /usr/bin/bitedj --resourcePath /usr/share/mixxx/ --full-screen --style Fusion"
    else
        swaymsg exec "env PA_ALSA_PLUGHW=1 WLR_DRM_NO_MODIFIERS=1 QT_WAYLAND_SHELL_INTEGRATION=xdg-shell /usr/bin/mixxx --resourcePath /usr/share/mixxx/ --full-screen --style Fusion"
    fi
fi
