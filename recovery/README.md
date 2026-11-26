# Lenovo Tab TB311FU (`poplar`) recovery build notes

This directory holds recovery-specific configuration, separate from the LineageOS ROM product setup. The hardware tree is for the MediaTek MT8786 / MT6768 Wi-Fi tablet.

## Important layout facts

- There is **no dedicated recovery partition**. Stock uses Android boot header v4 and the recovery ramdisk is carried in `vendor_boot`.
- Build the recovery-bearing `vendor_boot` output; do not expect a standalone `recovery.img` or flash one to a made-up recovery partition.
- `recovery.fstab` is the recovery mount table. The regular Android fstab and ROM init scripts are not substitutes for it.
- `BoardConfig.mk` currently chooses a kernel from `kernel/lenovo/poplar` if a complete source tree is present, otherwise `prebuilt/Image.gz`. A successful build alone does not establish that the chosen kernel boots recovery or supports required touch, display, storage, and encryption features.

## Shared recovery board settings

`BoardConfigRecovery.mk` contains the recovery-specific variables intended to be included from the device `BoardConfig.mk` for a recovery build. It preserves the device's existing boot-v4/vendor_boot arrangement and points recovery to `recovery.fstab`. It deliberately does not define a recovery flashing partition, enable unverified data decryption, or alter the ROM's product packages.

For a local TWRP or OrangeFox source checkout, add this include after the device's base board settings:

```make
include device/lenovo/poplar/recovery/BoardConfigRecovery.mk
```

Use the recovery project's own supported product definition and branch. TWRP and OrangeFox source trees/build systems are not vendored here. The exact product target and whether the recovery framework can emit a vendor_boot recovery fragment depend on the chosen upstream branch; verify that integration before treating the output as flashable.

## TWRP

1. Sync a TWRP source tree compatible with the Android base and kernel/vendor interface used by this device.
2. Add this device tree at `device/lenovo/poplar` and include `recovery/BoardConfigRecovery.mk` from its `BoardConfig.mk` in the local recovery build.
3. Select the TWRP product target documented by that TWRP source tree, then build its recovery-bearing vendor boot image. Do not use the LineageOS `lineage_poplar` target as proof that TWRP is selected: on the normal LineageOS product it builds Lineage Recovery.
4. Check the image contents with the upstream boot-image tooling and confirm the recovery ramdisk is a vendor_boot fragment before any device testing.

## OrangeFox

OrangeFox uses its own source tree and device setup in addition to the shared hardware board configuration. `orangefox/vendorsetup.sh` contains only conservative, device-specific environment declarations; source it from the OrangeFox build environment as described by that checkout. Do not add a recovery install-partition path: this device has no standalone recovery partition.

Build the recovery-bearing vendor boot image using the target and commands documented by the exact OrangeFox source branch. Confirm the resulting image contains the OrangeFox recovery ramdisk and is compatible with this tablet's bootloader before testing.

## Validation still required on hardware

This branch has not been built or boot-tested as TWRP/OrangeFox in this workspace. Before calling a release ready, validate at minimum:

- the selected kernel, DTB/DTBO, boot-header-v4 arguments, and vendor_boot fragment layout;
- touchscreen orientation/input and 1200×1920 display initialization;
- partition discovery, dynamic/logical partition mounting, EROFS reads, and F2FS userdata handling;
- whether `/data` decryption is supported by the selected recovery base and required device/vendor components;
- ADB and USB behavior, sideload, reboot targets, and recovery logs;
- that format/wipe/flash actions cannot target protected calibration or firmware partitions unintentionally.

Do not treat the presence of a partition in `recovery.fstab` as evidence that it is safe to wipe or flash. Keep personal data backed up and validate recovery images on an expendable test setup first.
