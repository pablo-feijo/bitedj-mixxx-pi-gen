# Keep the boot-partition SSH sentinel as a second, first-boot-safe assertion in
# addition to ENABLE_SSH=1 enabling ssh.service during stage2.
if [ "${ENABLE_SSH}" = "1" ]; then
    touch "${ROOTFS_DIR}/boot/firmware/ssh"
    rm -f "${ROOTFS_DIR}/etc/ssh/sshd_not_to_be_run"
    install -m 644 files/bitedj-ssh-keygen.service \
        "${ROOTFS_DIR}/etc/systemd/system/bitedj-ssh-keygen.service"
    mkdir -p "${ROOTFS_DIR}/etc/systemd/system/ssh.service.d"
    install -m 644 files/10-bitedj-host-keys.conf \
        "${ROOTFS_DIR}/etc/systemd/system/ssh.service.d/10-bitedj-host-keys.conf"
    on_chroot << 'SSH_GATE'
        systemctl enable bitedj-ssh-keygen.service
        systemctl enable ssh.service
        test -x /usr/sbin/sshd
        test "$(systemctl is-enabled ssh.service)" = enabled
        test "$(systemctl is-enabled bitedj-ssh-keygen.service)" = enabled
        test "$(systemctl is-enabled regenerate_ssh_host_keys.service)" = enabled
        test ! -e /etc/ssh/sshd_not_to_be_run
        test -s /home/pi/.ssh/authorized_keys
        test "$(stat -c %a /home/pi/.ssh/authorized_keys)" = 600
        grep -Eq '^[[:space:]]*PasswordAuthentication[[:space:]]+no' /etc/ssh/sshd_config
        install -d -m 755 /run/sshd
        rm -f /etc/ssh/ssh_host_*_key*
        ssh-keygen -A
        sshd -t
        sshd -T | grep -qx 'passwordauthentication no'
        systemd-analyze verify bitedj-ssh-keygen.service ssh.service
        rm -f /etc/ssh/ssh_host_*_key*
SSH_GATE
fi

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
