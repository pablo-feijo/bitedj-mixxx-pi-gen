# BiteDJ Custom OS - Networking & Audio Infrastructure

This document serves as a complete, versioned record of the custom UI and low-level audio fixes applied to the Raspberry Pi OS build to make it touch-friendly and resolve Bluetooth/ALSA conflicts.

## 1. Custom Touch-Friendly Networking GUIs

The default `blueman-manager` and `nmtui` managers were notoriously buggy and difficult to use on small touchscreens. Both have been completely replaced with custom hybrid `zenity` wrappers that directly interface with the low-level system daemons.

### Wi-Fi Manager (`bitedj-wifi.sh`)
- **Location:** `mixxx-pi-gen/stage3/02-desktop/files/bitedj-wifi.sh`
- **Behavior:**
  - Automatically suspends Mixxx fullscreen to draw over the UI.
  - Triggers a raw `nmcli device wifi list` scan.
  - Renders a touch-friendly `zenity --list` matrix of available SSIDs and their signal strengths.
  - On selection, prompts for a password via an obscured `zenity --password` modal.
  - Connects securely using the NetworkManager CLI.

### Bluetooth Manager (`bitedj-bt.sh`)
- **Location:** `mixxx-pi-gen/stage3/02-desktop/files/bitedj-bt.sh`
- **Behavior:** 
  - Completely bypasses `blueman-manager` for connecting known devices.
  - Queries `bluetoothctl devices Paired` (updated for BlueZ 5.66+).
  - Displays a massive 1-tap list of paired headphones.
  - Automatically injects an explicit `disconnect` command before `connect` to guarantee the A2DP profile initializes without throwing "Device or Resource Busy" DBus errors.
  - Includes a pinned `[Disconnect Current Device]` option to instantly route audio back to the physical outputs.
  - Includes a `[Pair New Device...]` fallback that opens the traditional `blueman-manager` for first-time pairings.

---

## 2. Audio Engine Stability Fixes (PortAudio + PipeWire)

Routing Mixxx's Master output to a Bluetooth headset while simultaneously routing the CUE output to the raw DDJ-400 hardware presented massive timing and resource conflicts on Linux. The following fixes were permanently embedded into the OS builder.

### WirePlumber 0.5 SPA-JSON Fix
- **Location:** `mixxx-pi-gen/stage3/02-desktop/files/wireplumber/wireplumber.conf.d/51-ignore-ddj400.conf`
- **Problem:** WirePlumber aggressively hijacked the DDJ-400, causing a resource collision when Mixxx tried to claim it, resulting in the playhead completely freezing.
- **Solution:** Migrated the old Lua script into the new WirePlumber 0.5 `SPA-JSON` format. The daemon now completely ignores `alsa_card.*DDJ-400*`, granting Mixxx 100% exclusive access.

### PipeWire Clock-Sync Injection
- **Location:** `mixxx-pi-gen/stage3/02-desktop/files/i3.conf`
- **Problem:** When PortAudio tried to talk to the `default` PipeWire server, their memory clocks misaligned, generating thousands of `paOutputUnderflow` errors per second.
- **Solution:** Injected `env PIPEWIRE_LATENCY="1024/44100"` into the Sway `bitedj` launch string. This forcefully synchronizes the daemon's clock with PortAudio, eliminating buffer underruns over wireless connections.

### ALSA Hardware Un-Hiding
- **Location:** `mixxx-pi-gen/stage3/02-desktop/files/i3.conf`
- **Problem:** When attempting to route the CUE, the DDJ-400 vanished from the Mixxx sound preferences dropdown.
- **Solution:** Re-injected the `PA_ALSA_PLUGHW=1` environment variable. This allows PortAudio to bypass the software mixer and probe the raw hardware nodes (`hw:CARD=DDJ400`), restoring it in the UI.

### Custom Bluetooth Naming Alias
- **Location:** `mixxx-pi-gen/stage3/02-desktop/02-run.sh`
- **Problem:** The option to select the Bluetooth headset was labeled as a highly confusing `default` in the Mixxx UI.
- **Solution:** Automatically generates a `~/.asoundrc` alias containing:
  ```text
  pcm.Bluetooth {
      type plug
      slave.pcm "default"
      hint { show on; description "Bluetooth Headphones (Wireless)" }
  }
  ```
  Mixxx now dynamically lists **Bluetooth Headphones (Wireless)** as a primary soundcard option.
