# Lenovo Tab TB311FU (`poplar`) recovery builders

Recovery-only build helpers and notes for the MediaTek MT8786 / MT6768 Wi-Fi tablet. This directory is intentionally separate from the LineageOS ROM product setup.

## Device image layout

- TB311FU has **no dedicated recovery partition**. Its boot images use Android boot header v4; recovery is carried in the `vendor_boot` image.
- The supported build output here is `vendorbootimage`. These scripts do not create or flash a standalone `recovery.img` and never issue fastboot commands.
- `recovery.fstab` is the recovery mount table. The regular Android fstab and ROM init scripts are not substitutes.
- The base `BoardConfig.mk` selects the available device kernel source when present, otherwise the checked-in `prebuilt/Image.gz`. Neither choice is proof that recovery display, touchscreen, storage, and encryption work.
- You must use a TWRP/OrangeFox source checkout compatible with this Android base and its vendor/kernel interface. Recovery source trees are not included here.

## Preparation

From the root of the chosen recovery source checkout, put this tree at `device/lenovo/poplar`, and make sure its required Android source projects and device-specific vendor/kernel inputs are synced. Select a lunch product that is actually defined by that recovery checkout. These helpers deliberately require `--lunch` rather than guessing product names that may not exist in a given fork.

The recovery board settings live in `recovery/BoardConfigRecovery.mk` and are included by this branch's `BoardConfig.mk`. The OrangeFox setup file is `recovery/orangefox/vendorsetup.sh`; the OrangeFox builder sources it automatically. TWRP-specific optional setup can be passed with `--setup-script` if your TWRP tree requires one.

## TWRP builder

```bash
./device/lenovo/poplar/recovery/build-twrp.sh --lunch <TWRP_PRODUCT>
```

Options:

```text
--lunch PRODUCT       Required, exact lunch target from the TWRP checkout
--jobs N              Parallel build jobs (defaults to online CPU count)
--target TARGET       Only vendorbootimage is accepted
--setup-script FILE   Source an optional TWRP/device setup script
--clean               Run m installclean before the build
--dry-run             Validate paths/options and print the plan only
--help                Show options
```

## OrangeFox builder

```bash
./device/lenovo/poplar/recovery/build-orangefox.sh --lunch <ORANGEFOX_PRODUCT>
```

The OrangeFox builder sources `recovery/orangefox/vendorsetup.sh` for `poplar` before lunch. Use `--setup-script FILE` to replace it with a setup script required by your checkout. Options are the same as the TWRP builder.

Both builders execute `m -jN vendorbootimage` after lunch. To inspect arguments without starting a build:

```bash
./device/lenovo/poplar/recovery/build-twrp.sh --lunch <TWRP_PRODUCT> --jobs 8 --dry-run
./device/lenovo/poplar/recovery/build-orangefox.sh --lunch <ORANGEFOX_PRODUCT> --dry-run
```

The helpers must be run from the Android source root. They don't sync source repositories, modify the device tree, or flash images. A completed build is not hardware validation: inspect the produced vendor_boot ramdisk/table with the tools from that source tree and verify its recovery fragment before any boot/flash testing.

## Required validation before release

Test on the exact TB311FU hardware and stock firmware baseline. At minimum verify:

- boot header v4, DTB/DTBO and vendor_boot fragment composition;
- touchscreen orientation/input and 1200×1920 display initialization;
- physical and logical partition discovery, dynamic partition mounting, EROFS reads, and F2FS userdata handling;
- `/data` decryption only if the chosen recovery base and required components demonstrably support it;
- ADB/USB, sideload, reboot destinations, and recovery logs;
- safe mount/format/flash behavior, especially for calibration, NV, bootloader, and other firmware partitions.

Do not infer that a partition is safe to wipe or flash merely because it appears in `recovery.fstab`. Keep a complete backup and validate on a recoverable test setup. Do not distribute as build-ready until build and device validation are recorded.
