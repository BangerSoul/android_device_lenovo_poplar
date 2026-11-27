#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/twrp_poplar.mk \
    $(LOCAL_DIR)/aosp_poplar.mk \
    $(LOCAL_DIR)/lineage_poplar.mk

COMMON_LUNCH_CHOICES := \
    twrp_poplar-eng \
    twrp_poplar-userdebug \
    aosp_poplar-userdebug \
    aosp_poplar-eng \
    lineage_poplar-userdebug \
    lineage_poplar-eng
