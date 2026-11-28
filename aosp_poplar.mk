#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Pure AOSP recovery entrypoint (RECOVERY_VARIANT=aosp).

RECOVERY_VARIANT ?= aosp

$(call inherit-product, device/lenovo/poplar/poplar_recovery_base.mk)

# Pure AOSP lacks vendor/*/build/tasks/kernel.mk; stage prebuilt GKI kernel as $(PRODUCT_OUT)/kernel.
PRODUCT_COPY_FILES += \
    device/lenovo/poplar/prebuilt/Image.gz:kernel

PRODUCT_NAME := aosp_poplar
