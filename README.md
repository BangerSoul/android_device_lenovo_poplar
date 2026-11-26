# Lenovo Tab TB311FU (`poplar`) device tree

This is the device configuration for the Lenovo Tab Wi-Fi (`TB311FU`, codename `poplar` / `poplar_row_wifi`) targeting LineageOS 21.0.

## Device summary

- **Platform:** MediaTek MT8786 / Helio G85 (`mt6768`, board `tb8786p1_64_k66`)
- **Display:** 1200 × 1920
- **Boot:** Android boot header v4, A/B and Virtual A/B
- **Partitions:** dynamic logical partitions in `super`; EROFS system partitions and F2FS userdata
- **Recovery:** no dedicated recovery partition; recovery is provided in `vendor_boot`

## Tree integration

The device tree expects the proprietary vendor tree at `vendor/lenovo/poplar` and the kernel tree at `kernel/lenovo/poplar`. Keep all three trees on compatible revisions:

```bash
git clone -b lineage-21.0 https://github.com/BangerSoul/android_device_lenovo_poplar.git device/lenovo/poplar
git clone -b lineage-21.0 https://github.com/BangerSoul/proprietary_vendor_lenovo_poplar.git vendor/lenovo/poplar
git clone -b lineage-21.0 https://github.com/BangerSoul/android_kernel_lenovo_poplar.git kernel/lenovo/poplar
```

The device configuration builds the kernel from source when a full kernel tree is present and otherwise uses `prebuilt/Image.gz`. Confirm that the kernel and vendor inputs match the target ROM and device firmware before building.

## LineageOS build

From a compatible LineageOS 21.0 source checkout with the trees above installed:

```bash
source build/envsetup.sh
lunch lineage_poplar-userdebug
m bacon
```

`m vendorbootimage` builds the image that carries recovery resources. There is no standalone recovery partition/image for this device.

## TWRP and OrangeFox

Recovery builders and recovery-specific configuration are maintained on the device repository's [`recovery/twrp-orangefox` branch](https://github.com/BangerSoul/android_device_lenovo_poplar/tree/recovery/twrp-orangefox). That branch documents supported builder flags, source-branch selection, and hardware validation. These helpers build `vendorbootimage` only and never flash the device.

## Safety

This repository is the device configuration; proprietary files are maintained separately in [proprietary_vendor_lenovo_poplar](https://github.com/BangerSoul/proprietary_vendor_lenovo_poplar). Recovery mount entries are not permission to wipe or flash partitions. Preserve full backups and protect calibration, NV, bootloader, and firmware partitions.
