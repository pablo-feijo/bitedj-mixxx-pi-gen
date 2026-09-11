# Enable ssh.
# touch ${ROOTFS_DIR}/boot/ssh

# Boot to graphical by default
on_chroot << EOF
	systemctl set-default graphical.target
EOF

install -m 644 files/autologin.conf ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf

# The GUI stays under pi for PipeWire and library ownership. System settings
# use noninteractive sudo; fail the image build if the policy/helper is broken.
rm -f ${ROOTFS_DIR}/etc/sudoers.d/010_pi-nopasswd
install -m 440 files/010_pi-nopasswd "${ROOTFS_DIR}/etc/sudoers.d/"
install -D -m 755 files/bitedj-check-system-settings "${ROOTFS_DIR}/usr/lib/bitedj/check-system-settings"
on_chroot << 'SYSTEM_SETTINGS'
    visudo -cf /etc/sudoers
    systemctl enable systemd-timesyncd.service
    runuser -u pi -- /usr/lib/bitedj/check-system-settings
SYSTEM_SETTINGS

echo pi - memlock unlimited >> ${ROOTFS_DIR}/etc/security/limits.conf
echo pi - rtprio 99 >> ${ROOTFS_DIR}/etc/security/limits.conf

# Allow pi user to mount and unmount USB drives without password
install -m 644 files/50-udisks.rules ${ROOTFS_DIR}/etc/polkit-1/rules.d/
install -m 644 files/69-mixxx-usb-uaccess.rules ${ROOTFS_DIR}/etc/udev/rules.d/
install -m 644 files/99-bitedj-usb-storage.rules ${ROOTFS_DIR}/etc/udev/rules.d/
