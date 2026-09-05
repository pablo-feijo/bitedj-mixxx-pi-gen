# Add i3/sway config file
mkdir -p -m 755 ${ROOTFS_DIR}/home/pi/.config/sway/
install -m 755 files/i3.conf ${ROOTFS_DIR}/home/pi/.config/sway/config
mkdir -p -m 755 ${ROOTFS_DIR}/home/pi/.config/xdg-desktop-portal/
install -m 644 files/xdg-desktop-portal-sway.conf ${ROOTFS_DIR}/home/pi/.config/xdg-desktop-portal/sway.conf
mkdir -p -m 755 ${ROOTFS_DIR}/home/pi/.config/systemd/user/
install -m 644 files/systemd/user/sway-session.service ${ROOTFS_DIR}/home/pi/.config/systemd/user/
install -m 644 files/systemd/user/sway-session.target ${ROOTFS_DIR}/home/pi/.config/systemd/user/
ln -sf /dev/null ${ROOTFS_DIR}/home/pi/.config/systemd/user/xdg-desktop-portal-gtk.service
ln -sf /dev/null ${ROOTFS_DIR}/home/pi/.config/systemd/user/xdg-desktop-portal-wlr.service
mkdir -p -m 755 ${ROOTFS_DIR}/home/pi/.config/sway/scripts/
install -m 755 files/sway/scripts/auto_exit_fullscreen.sh ${ROOTFS_DIR}/home/pi/.config/sway/scripts/
# install -m 755 files/scripts/pipewire-toggle.sh ${ROOTFS_DIR}/home/pi/
cp -r files/wallpaper ${ROOTFS_DIR}/home/pi/
cp -r files/i3blocks ${ROOTFS_DIR}/home/pi/.config/
cp -r files/waybar  ${ROOTFS_DIR}/home/pi/.config/
on_chroot << EOF
    chown -R pi:root /home/pi/.config/
    chmod -R 755 /home/pi/.config/
    chown -R pi:root /home/pi/wallpaper/
EOF

# Add mixxx default sound config
mkdir -p -m 755 ${ROOTFS_DIR}/home/pi/.mixxx/
install -m 644 files/soundconfig.xml ${ROOTFS_DIR}/home/pi/.mixxx/soundconfig.xml
on_chroot << CHROOT_EOF
    chown -R pi:root /home/pi/.mixxx/
    chmod -R 755 /home/pi/.mixxx/
CHROOT_EOF

# Fix missing default.qss for BiteDJ dropdown menus
mkdir -p -m 755 ${ROOTFS_DIR}/usr/share/mixxx/skins/
install -m 644 files/default.qss ${ROOTFS_DIR}/usr/share/mixxx/skins/default.qss

# Install first-boot auto-resize service
install -m 644 files/bitedj-resize.service ${ROOTFS_DIR}/etc/systemd/system/
touch ${ROOTFS_DIR}/etc/bitedj_first_boot
on_chroot << CHROOT_EOF
    systemctl enable bitedj-resize.service
CHROOT_EOF
install -m 755 files/bitedj-wifi.sh "${ROOTFS_DIR}/usr/bin/bitedj-wifi"
