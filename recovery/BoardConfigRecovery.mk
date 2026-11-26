# SPDX-License-Identifier: Apache-2.0
#
# Optional recovery-only settings for this device.
# Kept separate from ROM product settings to make the recovery boundary clear.

RECOVERY_VARIANT ?= twrp
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# TB311FU has no dedicated recovery partition. Recovery is carried by vendor_boot.
TARGET_NO_RECOVERY := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
