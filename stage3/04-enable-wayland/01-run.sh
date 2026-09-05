# Enable wayland
on_chroot << EOF
	SUDO_USER=pi raspi-config nonint do_boot_behaviour B4
	raspi-config nonint do_xcompmgr 0
	SUDO_USER=pi raspi-config nonint do_wayland W2
EOF

# Remove cups
on_chroot << EOF
    apt-get purge -y cups cups-common libcups2 system-config-printer printer-driver-* pocketsphinx-* pi-printer-support
    # apt-get autoremove -y
EOF

on_chroot << EOF
    # Ensure NetworkManager manages wifi
    sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
EOF

# Mask pipewire services
on_chroot << EOF
    mkdir -p /home/pi/.config/systemd/user/
    ln -sf /dev/null /home/pi/.config/systemd/user/pulseaudio.service
    ln -sf /dev/null /home/pi/.config/systemd/user/pulseaudio.socket
EOF
