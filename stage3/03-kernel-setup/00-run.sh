# Add preempt=full and splash kernel command line argument
on_chroot << EOF
    sed -i 's/$/ preempt=full cpufreq.default_governor=performance quiet splash plymouth.ignore-serial-consoles logo.nologo vt.global_cursor_default=0/' /boot/firmware/cmdline.txt
EOF

# Install custom Plymouth theme
mkdir -p "${ROOTFS_DIR}/usr/share/plymouth/themes/bitedj"
cp files/bitedj-plymouth/bitedj.plymouth "${ROOTFS_DIR}/usr/share/plymouth/themes/bitedj/"
cp files/bitedj-plymouth/bitedj.script "${ROOTFS_DIR}/usr/share/plymouth/themes/bitedj/"
# We copy the new pioneer splash from the plymouth theme folder
cp files/bitedj-plymouth/pioneer.png "${ROOTFS_DIR}/usr/share/plymouth/themes/bitedj/wallpaper.png"
cp files/bitedj-plymouth/pioneer-portrait.png "${ROOTFS_DIR}/usr/share/plymouth/themes/bitedj/wallpaper-portrait.png"

on_chroot << EOF
    plymouth-set-default-theme -R bitedj
EOF
