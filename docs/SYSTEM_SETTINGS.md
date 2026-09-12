# Clock and overclock support

BiteDJ runs as the normal `pi` desktop user. The image retains its existing
passwordless sudo policy; the app elevates clock changes, the headless
boot-settings helper, system restart/power-off and SSH service mutations.
Running the GUI as root would use different library and audio settings.

Stage 3 installs sudo, systemd/timedatectl, timesyncd and timezone data, validates
sudoers, enables time synchronization, and runs the read-only capability check
as `pi`. A missing helper or permission failure stops image creation. Run the
same check on a booted Pi with `/usr/lib/bitedj/check-system-settings`.

Settings > Info > SSH Remote Access reads the service without elevation and
uses `sudo -n systemctl enable --now ssh.service` or `disable --now` to change
it. Authentication remains key-only. Restart system from Power or Overclock and
Power off use the same noninteractive sudo path; no graphical Polkit agent or
password prompt is required.

The matching parent `dist-linux` supplies both the GUI and its helper. Save
boot settings in Settings > System > Overclock, then restart the system to
apply them. The helper validates the Pi model, values and original file hash,
backs up the original and writes only the fixed boot configuration path.
The image retains the approved 2000 MHz CPU / 750 MHz GPU / voltage 6 defaults;
never copy a test board's temporary changes into the recipe.

For hardware validation, coordinate exclusive device access, record the current
timezone/NTP and boot configuration, test a timezone change and restore it, then
save the existing overclock values through the app. Verify the backup and values
before a coordinated reboot. Preserve the normal user's library and settings.
