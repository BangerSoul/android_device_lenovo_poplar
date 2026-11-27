#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# TWRP / OrangeFox product entrypoint (select via RECOVERY_VARIANT=twrp|orangefox).

RECOVERY_VARIANT ?= twrp

$(call inherit-product, device/lenovo/poplar/poplar_recovery_base.mk)

PRODUCT_NAME := twrp_poplar
