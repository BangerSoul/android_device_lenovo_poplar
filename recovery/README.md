# Lenovo Tab TB311FU (`poplar`) recovery builders

Recovery-device configuration and build helpers for TWRP and OrangeFox on the Lenovo Tab Wi-Fi (`TB311FU`, codename `poplar` / `poplar_row_wifi`). Keep this recovery work on the dedicated [`recovery/twrp-orangefox` branch](https://github.com/BangerSoul/android_device_lenovo_poplar/tree/recovery/twrp-orangefox); the main LineageOS device configuration remains on `lineage-21.0`.

## Device layout and reference trees

- MediaTek MT8786 / MT6768, Android boot header v4, A/B and Virtual A/B.
- There is **no dedicated recovery partition**. Recovery is carried in `vendor_boot`; the supported output target is `vendorbootimage`.
- `recovery.fstab` describes recovery mount points; it is not permission to wipe or flash a partition.
- Keep device, vendor, kernel, and recovery-source inputs compatible. The device and vendor reference projects document the target platform and stock baseline: [device tree](https://github.com/BangerSoul/android_device_lenovo_poplar/tree/lineage-21.0), [proprietary vendor tree](https://github.com/BangerSoul/proprietary_vendor_lenovo_poplar/tree/lineage-21.0), and [kernel tree](https://github.com/BangerSoul/android_kernel_lenovo_poplar/tree/lineage-21.0). The vendor tree is based on stock build `TB311FU_ROW_OPEN_USER_M1457.5_W_ZUI_17.5.36.508_ST_261024`; do not mix blobs or kernel inputs from another model/firmware without validating compatibility.
- Recovery source code is not included. Choose the TWRP or OrangeFox source branch and its matching lunch product explicitly; this builder does not guess branch names, change branches, or sync repositories.

## Prepare the workspace

From the root of a compatible Android recovery checkout, place this tree at `device/lenovo/poplar` and provide the matching vendor project at `vendor/lenovo/poplar`. Provide `kernel/lenovo/poplar`, or use the device tree's `prebuilt/Image.gz` fallback. Check branch compatibility before building. The branch verifier accepts any number of `PATH=BRANCH` checks, so you can select the recovery source branch in your checkout and validate the device/vendor/kernel branches independently.

The recovery board configuration is `recovery/BoardConfigRecovery.mk`; OrangeFox device setup defaults to `recovery/orangefox/vendorsetup.sh`. The builder never runs `fastboot` and never flashes images.

## TWRP builder

```bash
./device/lenovo/poplar/recovery/build-twrp.sh --lunch <TWRP_PRODUCT>
```

## OrangeFox builder

```bash
./device/lenovo/poplar/recovery/build-orangefox.sh --lunch <ORANGEFOX_PRODUCT>
```

## Options (both builders)

```text
--lunch PRODUCT          Required exact lunch target provided by your recovery checkout
--jobs N                 Parallel jobs (default: detected online CPU count, or 1)
--target TARGET          Only vendorbootimage is accepted for this device
--setup-script FILE      Source an optional device setup script before lunch
--expect-branch PATH=BRANCH
                         Verify an existing Git checkout is on the requested branch; repeatable
--clean                  Run installclean before the build
--dry-run                Validate required trees/options/branches and print the plan
-h, --help               Show help
```

`--expect-branch` verifies but does not check out branches or sync projects. Paths are relative to the Android source root (or can be absolute). For example, choose the recovery-framework source branch and product that your checkout supports, then assert the intended device/vendor/kernel branches:

```bash
./device/lenovo/poplar/recovery/build-twrp.sh \
  --lunch <TWRP_PRODUCT> --jobs 8 \
  --expect-branch device/lenovo/poplar=recovery/twrp-orangefox \
  --expect-branch vendor/lenovo/poplar=lineage-21.0 \
  --expect-branch kernel/lenovo/poplar=lineage-21.0 \
  --dry-run

./device/lenovo/poplar/recovery/build-orangefox.sh \
  --lunch <ORANGEFOX_PRODUCT> \
  --expect-branch device/lenovo/poplar=recovery/twrp-orangefox \
  --expect-branch vendor/lenovo/poplar=lineage-21.0 \
  --setup-script /path/to/device-setup.sh --clean
```

The default vendor tree branch is `lineage-21.0`; kernel is optional when the checked-in `prebuilt/Image.gz` fallback is used. Branch names for the recovery-source repository vary by framework/release, so use a branch and lunch product supported by that checkout rather than assuming a universal name. `--target` is deliberately restricted: this device has no physical recovery partition.

## Validate before release

Review the built image for boot header v4, vendor-boot ramdisk fragments, DTB/DTBO composition, and partition-size limits. Test on the exact TB311FU hardware and a recoverable setup: display/touch, ADB/USB, storage and decryption, dynamic logical mounts, EROFS reads, F2FS userdata behavior, sideload, reboot paths, and backup/restore. A dry run checks builder inputs and branch alignment only; it does not prove that the selected recovery branch builds or works on hardware.

Keep full backups. Protect calibration, NV, bootloader, and firmware partitions. A successful build is not hardware validation or evidence that a recovery build is stable; test thoroughly before distribution.
