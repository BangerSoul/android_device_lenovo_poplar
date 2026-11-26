# Lenovo Tab TB311FU (`poplar`) recovery device tree

This branch contains device-specific recovery configuration and TWRP/OrangeFox build helpers for the Lenovo Tab Wi-Fi (`TB311FU`, codename `poplar` / `poplar_row_wifi`). It is based on the device and proprietary vendor information maintained in the related LineageOS 21.0 trees.

## Platform

- MediaTek MT8786 / Helio G85 (`mt6768`, board `tb8786p1_64_k66`)
- 1200 × 1920 display
- Android boot header v4, A/B and Virtual A/B
- Dynamic logical partitions in `super`, EROFS system partitions, F2FS userdata
- No dedicated recovery partition; recovery is embedded in `vendor_boot`

## Recovery builds

Use a compatible TWRP or OrangeFox source checkout, select its supported source branch, sync its dependencies, and place this device tree at `device/lenovo/poplar`. Supply compatible kernel and vendor trees as required by that checkout. The related [proprietary vendor repository](https://github.com/BangerSoul/proprietary_vendor_lenovo_poplar) tracks LineageOS 21.0 vendor inputs and documents its stock-firmware baseline. Do not assume the vendor blobs or kernel are compatible with an arbitrary recovery base.

Builder instructions and options are in [`recovery/README.md`](recovery/README.md). The helpers build `vendorbootimage` only. They do not switch source branches, fetch repositories, or flash devices. Because TB311FU has no standalone recovery partition, do not treat a recovery image as a `recovery.img` flash target.

## Safety and validation

Validate boot header and ramdisk layout, image size, display and touch, mounts, dynamic partitions, filesystem handling, USB/ADB, sideload, reboot, and restore procedures on the exact hardware. Preserve complete backups and do not wipe or flash calibration, NV, bootloader, or firmware partitions. Do not describe a build as stable until it has passed hardware testing.
