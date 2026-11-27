#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Shared multi-variant product base for Lenovo Tab (TB311FU / XT2573-1 / poplar).
# Reused by twrp_poplar, aosp_poplar, and lineage_poplar with RECOVERY_VARIANT selection.

RECOVERY_VARIANT ?= twrp
SUPPORTED_RECOVERY_VARIANTS := aosp twrp orangefox
ifeq ($(filter $(RECOVERY_VARIANT),$(SUPPORTED_RECOVERY_VARIANTS)),)
    $(error Unsupported RECOVERY_VARIANT='$(RECOVERY_VARIANT)'; expected one of: $(SUPPORTED_RECOVERY_VARIANTS))
endif

# Inherit base 64-bit product definitions available in full or minimal manifests.
ifneq ($(wildcard $(SRC_TARGET_DIR)/product/core_64_bit_only.mk),)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
else ifneq ($(wildcard $(SRC_TARGET_DIR)/product/core_64_bit.mk),)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
endif

ifneq ($(filter $(RECOVERY_VARIANT),twrp orangefox),)
    ifneq ($(wildcard $(SRC_TARGET_DIR)/product/base.mk),)
        $(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
    else ifneq ($(wildcard $(SRC_TARGET_DIR)/product/full_base.mk),)
        $(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
    endif
    # Both minimal-manifest-twrp and OrangeFox provide vendor/twrp/config/common.mk
    ifneq ($(wildcard vendor/twrp/config/common.mk),)
        $(call inherit-product, vendor/twrp/config/common.mk)
    endif
else
    ifneq ($(wildcard vendor/lineage/config/common_full_tablet_wifionly.mk),)
        ifneq ($(wildcard $(SRC_TARGET_DIR)/product/full_base.mk),)
            $(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
        endif
        $(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)
    else
        ifneq ($(wildcard $(SRC_TARGET_DIR)/product/base.mk),)
            $(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
        else ifneq ($(wildcard $(SRC_TARGET_DIR)/product/full_base.mk),)
            $(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
        endif
    endif
endif

# Inherit shared poplar device configuration & recovery hardware stability assets
$(call inherit-product, device/lenovo/poplar/device.mk)

# Canonical Device Identity (Lenovo TB311FU / Moto Pad 60 Lite)
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
