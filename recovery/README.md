# Lenovo Tab TB311FU (`poplar`) recovery builders

This branch carries device-tree recovery configuration and build helpers for TWRP and OrangeFox on the Lenovo Tab Wi-Fi (`TB311FU`, `poplar` / `poplar_row_wifi`). It is a recovery-development branch, separate from the LineageOS ROM branch.

## Device and image layout

- MediaTek MT8786 / MT6768, 1200 × 1920 display, Android boot header v4.
- There is **no dedicated recovery partition**. Recovery is embedded in the `vendor_boot` image; the supported build target is `vendorbootimage`.
- `recovery.fstab` describes recovery mounts. It does not imply that listed partitions are safe to wipe or flash.
- The build uses the device tree's kernel source when available, otherwise its checked-in prebuilt kernel. Neither option proves that the kernel supports recovery display, touch, storage, or decryption.
- TWRP/OrangeFox source is not included. Use a recovery source checkout and branch compatible with the Android base and the device's vendor/kernel interface. Keep matching source inputs in each build workspace; avoid mixing incompatible branch revisions.

## Prepare a build workspace

From the root of a compatible Android/TWRP/OrangeFox source checkout, install this device tree at `device/lenovo/poplar` and provide compatible vendor and kernel trees at `vendor/lenovo/poplar` and `kernel/lenovo/poplar` where required by that source tree. Select the framework's own source branch before syncing; the builders do not switch branches or sync repositories for you.

The recovery-only board settings are in `recovery/BoardConfigRecovery.mk`. OrangeFox's device setup is in `recovery/orangefox/vendorsetup.sh`. The helpers intentionally do not run `fastboot` or flash anything.

## TWRP

Run from the Android source root, using the exact lunch product defined by your TWRP checkout:

```bash
./device/lenovo/poplar/recovery/build-twrp.sh --lunch <TWRP_PRODUCT>
```

## OrangeFox

Use the lunch product defined by your OrangeFox checkout. The builder sources this tree's `recovery/orangefox/vendorsetup.sh` for `poplar` by default:

```bash
./device/lenovo/poplar/recovery/build-orangefox.sh --lunch <ORANGEFOX_PRODUCT>
```

## Builder options

Both commands accept the same options:

```text
--lunch PRODUCT       Required, exact lunch target for the selected source branch
--jobs N              Parallel build jobs (default: online CPU count, or 1)
--target TARGET       Build target; only vendorbootimage is supported
--setup-script FILE   Source an additional device setup script before lunch
--clean               Run installclean before building
--dry-run             Validate settings and print the plan without building
-h, --help            Show help
```

`--target` is deliberately restricted: this device has no physical recovery partition, so the helper only requests `vendorbootimage`. Choose the source branch/product explicitly in your checkout; the builder does not guess whether a particular TWRP or OrangeFox branch is compatible.

Examples:

```bash
./device/lenovo/poplar/recovery/build-twrp.sh --lunch <TWRP_PRODUCT> --jobs 8 --dry-run
./device/lenovo/poplar/recovery/build-orangefox.sh --lunch <ORANGEFOX_PRODUCT> --setup-script /path/to/device-setup.sh --clean
```

The build output should be checked for boot header v4, expected vendor-boot ramdisk fragments, DTB/DTBO composition, and image size before any device testing.

## Hardware validation before release

Test on the exact TB311FU model and a recoverable setup. Verify display and touchscreen, partition discovery, dynamic logical mounts, EROFS reads, F2FS userdata behavior, ADB/USB, sideload, reboot destinations, and logs. Claim userdata decryption only if it has been demonstrated on-device with the selected recovery base and required components.

Keep full backups. Do not wipe or flash calibration, NV, bootloader, or firmware partitions. Do not distribute a build as stable until it has been tested on hardware and recovery/restore procedures are verified.
