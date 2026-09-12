#!/bin/sh
set -eu

SWAYMSG=${BITEDJ_SWAYMSG:-swaymsg}
BITEDJ_EXECUTABLE=${BITEDJ_EXECUTABLE:-/usr/bin/bitedj}

# The image keeps HDMI-A-1 forced for older panels whose EDID is unreliable.
# Prefer a connected DSI panel when present and disable that phantom HDMI output
# so the kiosk workspace cannot open on an invisible screen.
outputs=$("$SWAYMSG" -r -t get_outputs)
dsi_output=$(printf '%s\n' "$outputs" | jq -r '
    [.[] | select(.name == "DSI-1" or .name == "DSI-2") | .name][0] // empty')

if [ -n "$dsi_output" ]; then
    "$SWAYMSG" -- output HDMI-A-1 disable
    "$SWAYMSG" -- output "$dsi_output" enable mode 720x1280
    "$SWAYMSG" -- input type:touch map_to_output "$dsi_output"
else
    "$SWAYMSG" -- output HDMI-A-1 enable mode --custom 1024x600
    "$SWAYMSG" -- input type:touch map_to_output HDMI-A-1
fi

# A forced HDMI fallback can make Sway allocate workspace 1 to HDMI and focus a
# blank workspace 2 on DSI. Only one output is active now, so select the kiosk
# workspace before creating the application window.
"$SWAYMSG" -- workspace number 1

exec env \
    PIPEWIRE_LATENCY="1024/44100" \
    WLR_DRM_NO_MODIFIERS=1 \
    QT_WAYLAND_SHELL_INTEGRATION=xdg-shell \
    "$BITEDJ_EXECUTABLE" \
    --resourcePath /usr/share/mixxx/ \
    --full-screen \
    --style Fusion
