# Lenovo Tab TB311FU (`poplar`) recovery builders

Recovery-device configuration and build helpers for TWRP and OrangeFox on the Lenovo Tab Wi-Fi (`TB311FU`, codename `poplar` / `poplar_row_wifi`). This is a separate device-tree branch for recovery work, not a complete recovery source tree.

## Device layout and reference trees

- MediaTek MT8786 / MT6768, Android boot header v4, A/B and Virtual A/B.
- There is **no dedicated recovery partition**. Recovery is carried in `vendor_boot`; the supported output target is `vendorbootimage`.
- `recovery.fstab` describes recovery mount points; it is not permission to wipe or flash a partition.
- Use this device configuration with compatible kernel and vendor inputs. The related proprietary tree documents the Lenovo stock firmware baseline and blob provenance: [proprietary_vendor_lenovo_poplar](https://github.com/BangerSoul/proprietary_vendor_lenovo_poplar), branch `lineage-21.0`. The ROM device/vendor trees are on `lineage-21.0`; this recovery tree is on `recovery/twrp-orangefox`.
- Recovery source code is not included. Select and sync a TWRP or OrangeFox source branch that is compatible with its Android base and this device's boot/vendor interface. These scripts do not guess, fetch, or switch recovery source branches.

## Prepare the workspace

From the root of a compatible Android recovery checkout, place this tree at `device/lenovo/poplar` and provide matching vendor/kernel projects where required by the selected recovery base. Check branch alignment before building; optional `--expect-branch PATH=BRANCH` checks one or more already checked-out trees without modifying them.

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
--dry-run                Validate options/branches and print the plan without building
-h, --help               Show help
```

Example with explicit checkout-branch checks:

```bash
./device/lenovo/poplar/recovery/build-twrp.sh \
  --lunch <TWRP_PRODUCT> --jobs 8 \
  --expect-branch device/lenovo/poplar=recovery/twrp-orangefox \
  --expect-branch vendor/lenovo/poplar=lineage-21.0 \
  --dry-run

./device/lenovo/poplar/recovery/build-orangefox.sh \
  --lunch <ORANGEFOX_PRODUCT> --setup-script /path/to/device-setup.sh \
  --expect-branch device/lenovo/poplar=recovery/twrp-orangefox --clean
```

`--expect-branch` is a validation guard only; it does not checkout or update branches. The `--lunch` target must exist in the chosen recovery source tree. Do not mix branches or vendor/kernel inputs unless their compatibility is established.

## Validate before release

Review the built image for boot header v4, vendor-boot ramdisk fragments, DTB/DTBO composition, and partition-size limits. Test on the exact TB311FU hardware and a recoverable setup: display/touch, physical and dynamic logical partition discovery, EROFS reads, F2FS userdata behavior, ADB/USB, sideload, reboot destinations, logs, and restore paths. Only claim `/data` decryption after it has been demonstrated on-device with the selected base and required components.

Keep full backups. Protect calibration, NV, bootloader, and firmware partitions. A successful build is not hardware validation or evidence that a recovery build is stable; test thoroughly before distribution.
