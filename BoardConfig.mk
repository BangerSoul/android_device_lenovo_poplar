#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/lenovo/poplar

# Allow standalone minimal recovery builds when non-recovery HALs are absent
ifeq ($(ALLOW_MISSING_DEPENDENCIES),)
    ifneq ($(filter $(RECOVERY_VARIANT),twrp orangefox),)
        ALLOW_MISSING_DEPENDENCIES := true
    endif
endif

# Architecture (ARMv8.2-A 64-bit, 2x Cortex-A75 @ 2.0GHz + 6x Cortex-A55 @ 1.8GHz)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a75

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Platform / Bootloader (TB311FU / XT2573-1)
TARGET_BOARD_PLATFORM := mt6768
TARGET_BOOTLOADER_BOARD_NAME := tb8786p1_64_k66
TARGET_NO_BOOTLOADER := true
BOARD_HAS_MTK_HARDWARE := true

# Kernel (Linux 6.6 GKI 2.0, 4K Page Size, Boot Header v4)
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_USES_GENERIC_KERNEL_IMAGE := true

# Build kernel from source if full kernel tree is present; otherwise fall back to prebuilt GKI kernel.
ifneq ($(wildcard kernel/lenovo/poplar/Makefile),)
    TARGET_KERNEL_SOURCE := kernel/lenovo/poplar
    TARGET_KERNEL_CONFIG := tb311fu_defconfig
    TARGET_KERNEL_CLANG_COMPILE := true
else
    TARGET_NO_KERNEL := false
    TARGET_KERNEL_SOURCE := $(DEVICE_PATH)/no_kernel_src
    TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz
endif

# Include stock MT6768 DTB in vendor_boot when prebuilt DTB is present (prevents dtb size: 0).
ifneq ($(wildcard $(DEVICE_PATH)/prebuilt/dtb/*.dtb),)
    BOARD_INCLUDE_DTB_IN_BOOTIMG := true
    BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
    BOARD_MKBOOTIMG_ARGS += --dtb_offset 0x01F00000
endif

ifneq ($(wildcard $(DEVICE_PATH)/prebuilt/dtbo.img),)
    BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
endif

BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x07C08000
BOARD_TAGS_OFFSET := 0x0BC08000
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
BOARD_BOOTCONFIG += androidboot.hardware=mt8786
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_TAGS_OFFSET)
BOARD_RAMDISK_USE_LZ4 := true

# Partition Sizes (Verified 54-Partition GPT Layout)
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

# Virtual A/B & Dynamic Partitions (11.00 GiB super, 14 logical EROFS partitions)
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    init_boot \
    vendor_boot \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    system \
    system_ext \
    vendor \
    product \
    vendor_dlkm \
    odm_dlkm

# Android 12.1 (fox_12.1 / twrp-12.1, SDK <= 32) does not recognize system_dlkm in BOARD_MAIN_PARTITION_LIST.
ifeq ($(filter 29 30 31 32,$(PLATFORM_SDK_VERSION)),)
    AB_OTA_PARTITIONS += system_dlkm
endif

ifneq ($(wildcard $(DEVICE_PATH)/prebuilt/dtbo.img),)
    AB_OTA_PARTITIONS += dtbo
endif

BOARD_USES_METADATA_PARTITION := true
BOARD_SUPER_PARTITION_SIZE := 11811160064
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 11809062912
BOARD_MAIN_PARTITION_LIST := \
    system \
    system_ext \
    vendor \
    product \
    vendor_dlkm \
    odm_dlkm

ifeq ($(filter 29 30 31 32,$(PLATFORM_SDK_VERSION)),)
    BOARD_MAIN_PARTITION_LIST += system_dlkm
endif

# Filesystems (EROFS read-only logical images, F2FS userdata)
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
ifeq ($(filter 29 30 31 32,$(PLATFORM_SDK_VERSION)),)
    BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
    TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
endif
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_EROFS_PCLUSTER_SIZE := 262144
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
BOARD_ROOT_EXTRA_FOLDERS += lenovocust

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# HIDL / VINTF Manifest
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += $(DEVICE_PATH)/configs/vintf/framework_compatibility_matrix.xml

# Sepolicy (only included when MediaTek vendor sepolicy tree is present; minimal recovery manifests omit it)
ifneq ($(wildcard device/mediatek/sepolicy_vndr/SEPolicy.mk),)
    include device/mediatek/sepolicy_vndr/SEPolicy.mk
    ifneq ($(wildcard $(DEVICE_PATH)/sepolicy/vendor),)
        BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
    endif
endif

# Build Broken Rules
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_DUP_RULES := true

# Inherit proprietary vendor BoardConfig when vendor tree is present
ifneq ($(wildcard vendor/lenovo/poplar/BoardConfigVendor.mk),)
    include vendor/lenovo/poplar/BoardConfigVendor.mk
endif

# Multi-variant recovery configuration (aosp / twrp / orangefox)
include $(DEVICE_PATH)/recovery/BoardConfigRecovery.mk
