# LineageOS Device Tree for Lenovo Tab (`poplar` / `TB311FU`)

Device configuration for building **LineageOS** (`lineage-21.0` / `lineage-22.1`) for the **Lenovo Tab** (`TB311FU`), internal codename `poplar` (`poplar_row_wifi`), built on the MediaTek Helio G85 (`MT8786` / `MT6768`) platform.

---

## Device Specifications

| Component | Specification |
|---|---|
| **Commercial Model** | Lenovo TB311FU (`ro.config.lgsi.market_name=Lenovo Tab`) |
| **Codename** | `poplar` (`poplar_row_wifi`) |
| **Board / Platform** | `tb8786p1_64_k66` / `mt6768` (`tc422` base) |
| **SoC** | MediaTek MT8786 / Helio G85 (2x ARM Cortex-A75 @ 2.0 GHz + 6x ARM Cortex-A55 @ 1.8 GHz) |
| **GPU** | ARM Mali-G52 2EEMC2 @ 950 MHz (Vulkan + OpenGL ES 3.2) |
| **Userspace ABI & IPC** | Pure 64-bit (`arm64-v8a` primary, `armeabi-v7a` secondary) + 64-bit Binder IPC |
| **Display** | 10.1" 1200 x 1920 WUXGA IPS LCD (60 Hz, PWM backlight floor >= 48) |
| **Audio** | Dual stereo speakers (`MTK_AUDIO_NUMBER_OF_SPEAKER=2`), Awinic Smart PA (`aw883xx`) |
| **Battery** | 5,100 mAh Li-Po (15W USB-C charging) |
| **Kernel** | Linux 6.6.82 GKI 2.0 (`tb311fu_defconfig`, 4096-byte page size) |
| **Stock Firmware Baseline** | `TB311FU_ROW_OPEN_USER_M1457.5_W_ZUI_17.5.36.508_ST_261024` |

---

## Boot v4 Trinity & Embedded Recovery Architecture

The TB311FU uses **Android Boot Image Header v4** across three dedicated physical partition pairs (`_a` / `_b`) and has **no dedicated physical `recovery` partition**:

| Partition | Size | Purpose |
|---|---|---|
| `boot_a` / `boot_b` | 32 MiB (`33,554,432` bytes) | GKI 6.6.82 `Image.gz` kernel + Little Kernel pinned OEM RSA4096 VBMeta at `0xDE3000` (`14,561,280`) |
| `init_boot_a` / `init_boot_b` | 8 MiB (`8,388,608` bytes) | Generic Android first-stage userspace ramdisk |
| `vendor_boot_a` / `vendor_boot_b` | 64 MiB (`67,108,864` bytes) | Vendor Ramdisk Table: Entry 0 (`type=1`, `vendor`) + Entry 1 (`type=2`, `recovery`), plus DTB |
| `dtbo_a` / `dtbo_b` | 8 MiB (`8,388,608` bytes) | Device Tree Blob Overlays |

In `BoardConfig.mk`:
- `BOARD_BOOT_HEADER_VERSION := 4`
- `TARGET_NO_RECOVERY := true`
- `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true`
- `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`

---

## Dynamic Partitions & Virtual A/B (`super`)

The device implements **Virtual A/B (VAB)** with an **11.00 GiB** physical `super` container (GPT partition index 52):

- `BOARD_SUPER_PARTITION_SIZE := 11811160064` (11.00 GiB)
- `BOARD_SUPER_PARTITION_GROUPS := main`
- `BOARD_MAIN_SIZE := 11809062912` (`super` minus 2 MiB `liblp` metadata overhead)
- **Logical Partitions** (14 total across `_a` / `_b`, formatted as **EROFS** with `pcluster_size = 262144`):
  - `system`, `system_ext`, `vendor`, `product`, `vendor_dlkm`, `system_dlkm`, `odm_dlkm`
- **Userdata**: **F2FS** with `inlinecrypt` (`aes-256-xts:aes-256-cts:v2` metadata-encrypted via `/metadata/vold/metadata_encryption`).

---

## Tree Structure

- `AndroidProducts.mk` / `lineage_poplar.mk`: Product entrypoints and `COMMON_LUNCH_CHOICES` (`lineage_poplar-user`, `lineage_poplar-userdebug`, `lineage_poplar-eng`).
- `BoardConfig.mk`: Architecture, kernel, Boot v4, Virtual A/B, EROFS/F2FS, AVB 2.0, and vendor `BoardConfigVendor.mk` integration.
- `device.mk`: Inherits `vendor/lenovo/poplar/poplar-vendor.mk`, declares HAL `PRODUCT_PACKAGES`, permissions, rootdir, and media/audio configs.
- `recovery.fstab`: EROFS/ext4 dynamic logical partition mounts, encrypted F2FS userdata, protected calibration partitions (`protect1`, `protect2`, `nvdata`, `nvram`, `proinfo`), and Boot v4 physical targets.
- `rootdir/etc/`: `fstab.mt6768`, `init.mt6768.rc` (includes `fastbootd`), `init.target.rc`, `init.connectivity.rc`, `ueventd.mt6768.rc`.
- `configs/`, `overlay/`, `sepolicy/vendor/`: Audio/Media/VINTF manifests, tablet resource overlays, and vendor SEPolicy definitions.

---

## Build Instructions

1. Initialize and sync the LineageOS workspace using `.repo/local_manifests/poplar.xml`.
2. Verify `vendor/lenovo/poplar` and `kernel/lenovo/poplar` are synced alongside `device/lenovo/poplar`.
3. Choose either **inline kernel compilation** or **prebuilt GKI kernel fallback** (handled automatically by `BoardConfig.mk` via `$(wildcard kernel/lenovo/poplar/Makefile)`):
   - **Inline kernel source**: Extract the Lenovo GPL `kernel-6.6` archive or clone `kernel_lenovo_TB311FU` into `kernel/lenovo/poplar/` (with `tb311fu_defconfig` and patches applied). `BoardConfig.mk` detects `kernel/lenovo/poplar/Makefile` and sets `TARGET_KERNEL_SOURCE := kernel/lenovo/poplar` + `TARGET_KERNEL_CONFIG := tb311fu_defconfig`.
   - **Prebuilt GKI kernel fallback**: When `kernel/lenovo/poplar/` only contains config/patches/tools (no `Makefile`), `BoardConfig.mk` falls back to `TARGET_PREBUILT_KERNEL := device/lenovo/poplar/prebuilt/Image.gz` (stage a standalone-compiled `Image.gz` or unpack stock `boot.img` via `python3 kernel/lenovo/poplar/tools/assemble_boot_vector.py --unpack boot.img`). Optionally stage `device/lenovo/poplar/prebuilt/dtbo.img` (copied from stock `dtbo.img`); `BoardConfig.mk` only sets `BOARD_PREBUILT_DTBOIMAGE` and adds `dtbo` to `AB_OTA_PARTITIONS` when `prebuilt/dtbo.img` is present, so omitting it keeps `m bacon` OTA packaging safe.
4. Build LineageOS:

```bash
source build/envsetup.sh
lunch lineage_poplar-userdebug
m bacon
```

To build only the recovery-bearing `vendor_boot` image:

```bash
m vendorbootimage
```

---

## Flashing Guide

> **Prerequisite**: Bootloader must be unlocked via the 356-byte Little Kernel `sn.img` token (`fastboot flash unlock sn.img && fastboot oem unlock`) or BROM `seccfg` unlock. Never wipe or flash `nvram`, `nvdata`, `protect1`, `protect2`, or `proinfo`.

### 1. Flash Static Boot v4 Trinity & VBMeta (Bootloader Fastboot Mode)

```bash
fastboot flash boot_a boot.img
fastboot flash init_boot_a init_boot.img
fastboot flash vendor_boot_a vendor_boot.img
fastboot flash dtbo_a dtbo.img
fastboot --disable-verity --disable-verification flash vbmeta_a vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system_a vbmeta_system.img
fastboot --disable-verity --disable-verification flash vbmeta_vendor_a vbmeta_vendor.img
```

### 2. Flash Dynamic Logical Partitions (Userspace `fastbootd` Mode)

```bash
fastboot reboot fastboot
fastboot flash system_a system.img
fastboot flash system_ext_a system_ext.img
fastboot flash product_a product.img
fastboot flash vendor_a vendor.img
fastboot flash vendor_dlkm_a vendor_dlkm.img
fastboot flash system_dlkm_a system_dlkm.img
fastboot flash odm_dlkm_a odm_dlkm.img
fastboot -w
fastboot reboot
```

Alternatively, sideload the compiled LineageOS OTA zip (`lineage-*.zip`) from LineageOS Recovery (`vendor_boot` Entry 1).

---

## Repository & GitHub Publishing

- **Remote (`origin`)**: `https://github.com/iamsh/android_device_lenovo_poplar.git`
- **Target Branch**: `lineage-21.0`

```bash
git remote -v
git push -u origin lineage-21.0
```
