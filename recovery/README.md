# Lenovo Tab TB311FU / Moto Pad 60 Lite (`poplar`) — Multi-Variant Recovery Hub

Unified recovery device configuration on the [`recovery/twrp-orangefox` branch](https://github.com/BangerSoul/android_device_lenovo_poplar/tree/recovery/twrp-orangefox) supporting **AOSP / LineageOS recovery**, **TWRP (`landscape_hdpi`)**, and **OrangeFox (`OF_LANDSCAPE_MODE`)** from one shared device tree via **`RECOVERY_VARIANT`** selection.

## Architecture & Inherited Stability

- **Boot v4 Vendor Boot Recovery:** `TB311FU` / `XT2573-1` (`tb8786p1_64_k66`, MT8786 / MT6768) has **no physical `recovery` partition**. Setting `BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true` embeds recovery into `vendor_boot.img` Vendor Ramdisk Entry 1 (`type=2`, `"recovery"`). The only supported recovery output target is `vendorbootimage`.
- **Kernel Stability Inherited (`kernel/lenovo/poplar`):**
  - Prebuilt Linux 6.6.82 GKI 2.0 `Image.gz` fallback when full kernel source is absent (automatically switches to `tb311fu_defconfig` source build if `kernel/lenovo/poplar/Makefile` exists).
  - Prebuilt stock MT6768 DTB (`prebuilt/dtb/mt6768.dtb`, `147,560` bytes, `--dtb_offset 0x01F00000`) included when present so `vendor_boot.img` carries valid board DTB (`dtb size != 0`).
  - Hardware PWM backlight calibration matching `patches/0001-backlight-floor-clamp-48.patch` (`/sys/class/leds/lcd-backlight/brightness`, `TW_MAX_BRIGHTNESS := 4095`, `TW_DEFAULT_BRIGHTNESS := 1024`) to prevent 0-nit blackout.
- **Vendor Stability Inherited (`vendor/lenovo/poplar`):**
  - Touchscreen drivers (`hx83102e.ko`, `jd9366ts.ko`, `nt36523h.ko`) and thermal/DVFS modules (`CPU_DVFS.ko`, `thermal_monitor.ko`) staged into recovery/vendor ramdisks when `vendor/lenovo/poplar` is synced.
  - TrustKernel/Beanpod TEE components (`teei_daemon`, `init_thh`, `libteei_daemon_vfs.so`) staged alongside FBE v2 decryption (`TW_INCLUDE_CRYPTO`, `TW_INCLUDE_FBE_METADATA_DECRYPT`, `TW_USE_FSCRYPT_POLICY := 2`).
  - Modern Linux 6.6 ConfigFS USB (`musb-hdrc`, `/config/usb_gadget/g1`) for ADB, sideload, fastbootd, and MTP in `recovery/root/init.recovery.usb.rc`.

## Variants (`RECOVERY_VARIANT`)

Reused shared product entrypoint (`poplar_recovery_base.mk` -> `device.mk` + `recovery/BoardConfigRecovery.mk`) across three lunch choices in `AndroidProducts.mk`:

| `RECOVERY_VARIANT` | Manifest Base | Lunch Target | UI & Orientation |
|---|---|---|---|
| `twrp` *(default)* | `minimal-manifest-twrp` (`twrp-12.1` / `twrp-14.1`) | `twrp_poplar-eng` | `TW_THEME := landscape_hdpi`, `TW_ROTATION := 270`, touch `SWAP_XY + FLIP_X` |
| `orangefox` | OrangeFox (`fox_12.1` / `fox_14.1`) | `twrp_poplar-eng` | `TW_THEME := portrait_hdpi` (upstream theme constraint) + `OF_LANDSCAPE_MODE := 1` (`270°`), `OF_VIRTUAL_AB_DEVICE=1`, `FOX_VENDOR_BOOT_RECOVERY=1` |
| `aosp` | AOSP (`android-14.0.0_r67`) or LineageOS `21.0` | `aosp_poplar-userdebug` / `lineage_poplar-userdebug` | Pure AOSP / Lineage recovery (`RGBX_8888`), fastbootd + boot/health HALs |

## Local Usage

Run from the root of the target manifest checkout (`AOSP`, `minimal-manifest-twrp`, or `OrangeFox`):

```bash
# 1. TWRP (landscape_hdpi)
./device/lenovo/poplar/recovery/build-twrp.sh --lunch twrp_poplar-eng

# 2. OrangeFox (landscape mode via OF_LANDSCAPE_MODE=1)
./device/lenovo/poplar/recovery/build-orangefox.sh --lunch twrp_poplar-eng

# 3. AOSP recovery
./device/lenovo/poplar/recovery/build-aosp.sh --lunch aosp_poplar-userdebug
```

Useful options: `--dry-run`, `--jobs N`, `--expect-branch PATH=BRANCH`, `--allow-missing-vendor`, `--clean`.

## GitHub Actions CI

`.github/workflows/build-recovery.yml` supports automated cloud builds for all three manifests (`twrp`, `orangefox`, `aosp`) with `RECOVERY_VARIANT` selection via `workflow_dispatch` (or `all`), verifies the resulting `vendor_boot.img` size/header/DTB/ramdisk table, generates `.sha256sum`, and uploads workflow artifacts.
