#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

RECOVERY_VARIANT ?= twrp

# Soong Namespaces (guarded for standalone minimal manifests)
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

ifneq ($(wildcard hardware/mediatek/Android.bp hardware/mediatek/Android.mk),)
PRODUCT_SOONG_NAMESPACES += \
    hardware/mediatek
endif

# Overlays & Screen Characteristics (10.1" 1200x1920 WUXGA IPS LCD, ~224 ppi, 60Hz)
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

PRODUCT_AAPT_CONFIG := normal large xlarge
PRODUCT_AAPT_PREF_CONFIG := xhdpi
PRODUCT_CHARACTERISTICS := tablet

# API Shipping Level & Dynamic Partitions / Virtual A/B
# Recovery manifests span Android 12.1..14.1; cap non-AOSP recovery shipping API at 32 so
# BOARD_SYSTEMSDK_VERSIONS (32) checks pass on fox_12.1 / twrp-12.1 as well as twrp-14.1.
ifeq ($(RECOVERY_VARIANT),aosp)
    PRODUCT_SHIPPING_API_LEVEL := 34
else
    PRODUCT_SHIPPING_API_LEVEL := 32
endif
PRODUCT_USE_DYNAMIC_PARTITIONS := true
ifneq ($(wildcard $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk),)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
endif
PRODUCT_VIRTUAL_AB_COW_VERSION := 2

# Inherit proprietary vendor blobs when vendor tree is present (guarded for minimal CI/AOSP manifests)
ifneq ($(wildcard vendor/lenovo/poplar/poplar-vendor.mk),)
    $(call inherit-product, vendor/lenovo/poplar/poplar-vendor.mk)
endif

# Audio & Media Configuration (full OS targets / VINTF compatibility)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(LOCAL_PATH)/configs/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

# Rootdir Scripts & Fstab (Early First-Stage Mount + Vendor Init + Ueventd)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt8786:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt8786 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt8786:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.mt8786 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt8786:$(TARGET_COPY_OUT_RECOVERY)/root/first_stage_ramdisk/fstab.mt8786 \
    $(LOCAL_PATH)/rootdir/etc/init.mt8786.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt8786.rc \
    $(LOCAL_PATH)/rootdir/etc/init.target.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.target.rc \
    $(LOCAL_PATH)/rootdir/etc/init.connectivity.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.connectivity.rc \
    $(LOCAL_PATH)/rootdir/etc/ueventd.mt6768.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Recovery Init, ConfigFS USB Gadget & Partition Flags (Vendor Boot Embedded Recovery)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt8786.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt8786.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt6768.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6768.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc \
    $(LOCAL_PATH)/recovery/twrp.flags:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/twrp.flags

# Inherit Touchscreen, DVFS, Thermal & TEE Stability Assets Directly into Recovery Ramdisk when Vendor Tree Exists
ifneq ($(wildcard vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/hx83102e.ko),)
PRODUCT_COPY_FILES += \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/hx83102e.ko:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/hx83102e.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/jd9366ts.ko:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/jd9366ts.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/nt36523h.ko:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/nt36523h.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/CPU_DVFS.ko:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/CPU_DVFS.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/thermal_monitor.ko:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/thermal_monitor.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/hx83102e.ko:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/hx83102e.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/jd9366ts.ko:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/jd9366ts.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/nt36523h.ko:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/nt36523h.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/CPU_DVFS.ko:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/CPU_DVFS.ko \
    vendor/lenovo/poplar/proprietary/vendor_dlkm/lib/modules/thermal_monitor.ko:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/thermal_monitor.ko
endif

ifneq ($(wildcard vendor/lenovo/poplar/proprietary/vendor/bin/teei_daemon),)
PRODUCT_COPY_FILES += \
    vendor/lenovo/poplar/proprietary/vendor/bin/teei_daemon:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/teei_daemon \
    vendor/lenovo/poplar/proprietary/vendor/bin/init_thh:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/init_thh \
    vendor/lenovo/poplar/proprietary/vendor/lib64/libteei_daemon_vfs.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libteei_daemon_vfs.so \
    $(foreach ta,$(wildcard vendor/lenovo/poplar/proprietary/vendor/thh/ta/*),$(ta):$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/$(notdir $(ta)))
endif

# Permissions & OS packages (included cleanly; ignored cleanly in minimal recovery builds)
ifneq ($(wildcard frameworks/native/data/etc/tablet_core_hardware.xml),)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2023-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2023-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml
endif

# Recovery HALs & Dynamic Partition Management
ifeq ($(RECOVERY_VARIANT),aosp)
PRODUCT_PACKAGES += \
    fastbootd \
    android.hardware.boot@1.2-impl.recovery \
    android.hardware.health-service.example_recovery
else
PRODUCT_PACKAGES += \
    fastbootd \
    lptools \
    resetprop \
    linker.recovery \
    android.hardware.boot@1.2-impl.recovery \
    android.hardware.health@2.1-impl.recovery
endif

# Full OS HAL Packages (skipped cleanly during standalone minimal TWRP/OrangeFox builds)
ifeq ($(RECOVERY_VARIANT),aosp)
PRODUCT_PACKAGES += \
    android.hardware.audio.service-aidl.mediatek \
    android.hardware.audio.effect.aidl-impl-mediatek \
    android.hardware.bluetooth.audio@2.1-impl \
    android.hardware.bluetooth-service-mediatek \
    android.hardware.camera.provider@2.6-impl-mediatek \
    android.hardware.fastboot@1.1-impl-mock \
    android.hardware.gnss-service.mediatek \
    android.hardware.graphics.allocator-V2-service-mediatek \
    android.hardware.graphics.composer@3.3-service \
    android.hardware.health-service.example \
    android.hardware.light-service.mediatek \
    android.hardware.memtrack-service.mediatek \
    android.hardware.power-service.mediatek \
    android.hardware.sensors-service.multihal \
    android.hardware.thermal-service.mediatek \
    android.hardware.usb-service.mediatek \
    android.hardware.wifi-service-lazy \
    PoplarWifiOverlay \
    wpa_supplicant \
    hostapd \
    libwpa_client
endif

# Virtual A/B Update Engine & Tools
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_engine_sideload \
    update_verifier

# Recovery Properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.fastbootd.available=true \
    ro.sys.usb.bicr=no \
    ro.sys.usb.storage.type=adb,mtp \
    persist.service.adb.enable=1 \
    persist.service.debuggable=1
