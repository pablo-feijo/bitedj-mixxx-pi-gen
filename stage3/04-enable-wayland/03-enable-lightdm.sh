#!/bin/bash -e
on_chroot << CHROOT_EOF
    systemctl enable lightdm
CHROOT_EOF
