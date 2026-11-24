#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Inherit from poplar device configuration.
$(call inherit-product, device/lenovo/poplar/device.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := lineage_poplar
PRODUCT_DEVICE := poplar
PRODUCT_BRAND := Lenovo
PRODUCT_MODEL := TB311FU
PRODUCT_MANUFACTURER := Lenovo

PRODUCT_GMS_CLIENTID_BASE := android-lenovo

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="TB311FU-user 16 BP2A.250605.031.A3 508 release-keys" \
    BuildFingerprint=alps/TB311FU/TB311FU:16/BP2A.250605.031.A3/36.508.261024W:user/release-keys \
    DeviceName=TB311FU \
    DeviceProduct=TB311FU \
    SystemDevice=TB311FU \
    SystemName=TB311FU
