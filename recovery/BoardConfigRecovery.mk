# SPDX-License-Identifier: Apache-2.0
#
# Multi-variant recovery configuration for Lenovo Tab (TB311FU / XT2573-1 / poplar).
# Select flavor via RECOVERY_VARIANT := aosp | twrp | orangefox (default: twrp).

RECOVERY_VARIANT ?= twrp
SUPPORTED_RECOVERY_VARIANTS := aosp twrp orangefox
ifeq ($(filter $(RECOVERY_VARIANT),$(SUPPORTED_RECOVERY_VARIANTS)),)
    $(error Unsupported RECOVERY_VARIANT='$(RECOVERY_VARIANT)'; expected one of: $(SUPPORTED_RECOVERY_VARIANTS))
endif

# ---------------------------------------------------------------------------
# Boot Header v4 Vendor Boot Recovery Layout (No physical recovery partition)
# ---------------------------------------------------------------------------
TARGET_NO_RECOVERY := true
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

# Guarded so minimal AOSP board_config.mk sanity checks pass when TARGET_NO_RECOVERY=true.
ifdef BUILDING_RECOVERY_IMAGE
    BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
endif

TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FORCE_PIXEL_FORMAT := RGBX_8888
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_USES_METADATA_PARTITION := true

# Native DSI hardware panel geometry (10.1" 1200x1920 WUXGA IPS LCD, 60Hz)
TARGET_SCREEN_WIDTH := 1200
TARGET_SCREEN_HEIGHT := 1920

# ---------------------------------------------------------------------------
# Hardware, Kernel & Vendor Stability Settings Shared Across Recoveries
# ---------------------------------------------------------------------------
# Inherited from kernel/lenovo/poplar/patches/0001-backlight-floor-clamp-48.patch (12-bit 0..4095 PWM)
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 4095
TW_DEFAULT_BRIGHTNESS := 1024

# CPU temperature sysfs & tablet hardware flags (no vibrator / haptics hardware)
TW_CUSTOM_CPU_TEMP_PATH := "/sys/devices/virtual/thermal/thermal_zone0/temp"
TW_NO_HAPTICS := true
TW_INPUT_BLACKLIST := "hbtp_vm"

# Use device ConfigFS USB initialization for MTK musb-hdrc on GKI 6.6
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_HAS_NO_RECOVERY_PARTITION := true
TW_NO_FLASH_CURRENT_TWRP := true

# Storage, Virtual A/B Dynamic Partitions & FBE v2 Decryption (aes-256-xts:aes-256-cts:v2 + inlinecrypt)
BOARD_SUPPRESS_SECURE_ERASE := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := 2
BOARD_USES_QCOM_FBE_DECRYPTION := false
TW_PREPARE_DATA_MEDIA_EARLY := true

# Dynamic partition / boot-repack / logging utilities
TW_INCLUDE_FASTBOOTD := true
TW_INCLUDE_LPTOOLS := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := en
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# Stage vendor recovery modules (touchscreen & thermal/DVFS) into recovery/vendor ramdisks via device.mk
# and load them in init.recovery.mt8786.rc (avoid TW_LOAD_VENDOR_MODULES + TARGET_PREBUILT_KERNEL,
# which triggers an upstream syntax error in vendor/twrp@android-14.1/build/tasks/kernel.mk:594).
TW_LOAD_VENDOR_BOOT_MODULES := true

# ---------------------------------------------------------------------------
# Recovery Variant Selection (RECOVERY_VARIANT)
# ---------------------------------------------------------------------------
ifeq ($(RECOVERY_VARIANT),twrp)
    # TWRP ships native 1920x1200 landscape_hdpi resources; rotate 1200x1920 panel 270 deg + map touch
    TW_THEME := landscape_hdpi
    TW_ROTATION := 270
    RECOVERY_TOUCHSCREEN_SWAP_XY := true
    RECOVERY_TOUCHSCREEN_FLIP_X := true
    TW_STATUS_ICONS_ALIGN := center
    TW_DEVICE_VERSION := poplar-TWRP
else ifeq ($(RECOVERY_VARIANT),orangefox)
    # OrangeFox upstream ships portrait_hdpi resources and applies 270 deg landscape via OF_LANDSCAPE_MODE
    TW_THEME := portrait_hdpi
    OF_LANDSCAPE_MODE := 1
    TW_ROTATION := 270
    RECOVERY_TOUCHSCREEN_SWAP_XY := true
    RECOVERY_TOUCHSCREEN_FLIP_X := true
    FOX_AB_DEVICE := 1
    FOX_VIRTUAL_AB_DEVICE := 1
    FOX_VENDOR_BOOT_RECOVERY := 1
    OF_ENABLE_LPTOOLS := 1
    OF_USE_MAGISKBOOT := 1
    OF_USE_MAGISKBOOT_FOR_ALL_PATCHES := 1
    OF_USE_LZ4_COMPRESSION := 1
    FOX_USE_NANO_EDITOR := 1
    OF_NO_TREBLE_COMPATIBILITY_CHECK := 1
    OF_MAINTAINER := BangerSoul
    TW_DEVICE_VERSION := poplar-OrangeFox
else ifeq ($(RECOVERY_VARIANT),aosp)
    # Pure AOSP / LineageOS Boot v4 embedded recovery UI
    TARGET_RECOVERY_UI_MARGIN_HEIGHT := 24
    RECOVERY_UI_PROGRESS_BAR_BASELINE := 259
endif
