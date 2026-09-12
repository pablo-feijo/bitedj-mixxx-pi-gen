# Touch Display 2 boot splash investigation

Status: unresolved on Raspberry Pi 5 with Touch Display 2. The application UI
is correctly landscape after Sway starts, but the Pioneer image remains cropped
in a portrait boot canvas.

## Reproduction and evidence

- Hardware: Raspberry Pi 5 Model B Rev 1.1, Touch Display 2 on `DSI-2`.
- Native DSI mode and framebuffer: 720x1280. Sway later exposes a 1280x720
  desktop with `transform 90` and must retain that working application profile.
- `plymouth-start.service` completes successfully, the `bitedj` theme is selected,
  and its files are present in the Pi 5 initramfs. There are no failed units.
- The separate firmware-level `splash.png` was disabled and renamed on the test
  card, proving the remaining cropped image is produced by Plymouth.
- Runtime `Image.Rotate(Math.Pi / 2)` did not change the physical result.
- A pre-rotated 600x1024 asset selected when the Plymouth window reports portrait
  also did not change the physical result.
- Removing `rotate=90` from the kernel DSI `video=` arguments, while retaining
  Sway's transform, also left the physical splash unchanged.

The current source retains the pre-rotated asset, disables the fixed firmware
splash, and leaves kernel DSI boot in its native mode. These are useful plumbing
for the next investigation, but they are not a validated visual fix.

## Next diagnostic

Capture Plymouth's boot-time debug log and determine the renderer's reported
pixel-display geometry, active DRM connector and selected asset. Do not infer
those values from the post-boot framebuffer. If the script window geometry does
not identify DSI reliably, select a DSI-specific theme before `plymouth-start`
from initramfs connector state instead of using `Window.GetWidth/Height`.

Acceptance requires all of the following on physical hardware:

- Touch Display 2 shows the full Pioneer image horizontally without cropping.
- The original 1024x600 HDMI profile remains horizontal and fully framed.
- No firmware image, boot text or cursor appears before Plymouth.
- Sway still presents Touch Display 2 as 1280x720 and touch remains mapped.
- SSH, BiteDJ startup and the firmware-default clock configuration survive reboot.
