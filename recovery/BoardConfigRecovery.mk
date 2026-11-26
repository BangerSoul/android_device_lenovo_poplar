# SPDX-License-Identifier: Apache-2.0
#
# Optional recovery-only settings for this device.
# Include this file from the device BoardConfig when building TWRP or OrangeFox.
# Keep device/lenovo/poplar/BoardConfig.mk as the source of the hardware and
# vendor_boot layout settings.

RECOVERY_VARIANT := twrp
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# This device has no dedicated recovery partition. Recovery is a vendor_boot
# ramdisk fragment; do not configure a recovery.img flash destination.
TARGET_NO_RECOVERY := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
