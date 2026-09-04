#!/bin/bash
set -e

# Optional: Extra small screen skins from upstream mixxx-pi-gen
# BiteDJ already includes its own custom touch skin at /usr/share/mixxx/skins/BiteDJ
mkdir -p "${ROOTFS_DIR}/usr/share/mixxx/skins/"

if [ ! -d files/pi_dj ]; then
    git clone --depth 1 https://github.com/dennisdebel/pi_dj.git files/pi_dj/ || true
fi
if [ -d files/pi_dj/mixxx/skin ]; then
    cp -r files/pi_dj/mixxx/skin/* "${ROOTFS_DIR}/usr/share/mixxx/skins/" || true
fi

if [ ! -d files/Pioneered ]; then
    git clone --depth 1 https://github.com/timewasternl/Pioneered files/Pioneered/ || true
fi
if [ -d files/Pioneered ]; then
    cp -r files/Pioneered "${ROOTFS_DIR}/usr/share/mixxx/skins/" || true
fi
