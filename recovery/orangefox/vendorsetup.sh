#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Device-specific OrangeFox setup for Lenovo Tab TB311FU / Moto Pad 60 Lite (poplar).

FDEVICE="poplar"

fox_get_target_device() {
    local chkdev
    chkdev=$(echo "$BASH_SOURCE" | grep -w "$FDEVICE" || true)
    if [ -n "$chkdev" ]; then
        FOX_BUILD_DEVICE="$FDEVICE"
    else
        chkdev=$(set | grep BASH_ARGV | grep -w "$FDEVICE" || true)
        [ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
    fi
}

if [ -z "${1:-}" ] && [ -z "${FOX_BUILD_DEVICE:-}" ]; then
    fox_get_target_device
fi

if [[ "${1:-}" == "$FDEVICE" || "${FOX_BUILD_DEVICE:-}" == "$FDEVICE" ]]; then
    export RECOVERY_VARIANT="orangefox"
    export FOX_BUILD_DEVICE="$FDEVICE"
    export TARGET_DEVICE="$FDEVICE"
    export TARGET_DEVICE_ALT="TB311FU,XT2573-1,poplar_row_wifi"
    export FOX_TARGET_DEVICES="poplar,TB311FU,XT2573-1,poplar_row_wifi"

    # Boot Header v4 vendor_boot recovery + Dynamic Partitions + Virtual A/B
    export FOX_AB_DEVICE=1
    export FOX_VIRTUAL_AB_DEVICE=1
    export FOX_VENDOR_BOOT_RECOVERY=1
    export OF_ENABLE_LPTOOLS=1
    export OF_USE_MAGISKBOOT=1
    export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1
    export OF_USE_LZ4_COMPRESSION=1

    # Tablet Landscape Orientation & Display Stability (10.1" 1200x1920 panel rotated 270 deg)
    export LC_ALL="C"
    export FOX_BUILD_TYPE="${FOX_BUILD_TYPE:-Unofficial}"
    export OF_LANDSCAPE_MODE=1
    export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
    export FOX_USE_NANO_EDITOR=1
    export FOX_ENABLE_APP_MANAGER=1
    export OF_MAINTAINER="BangerSoul"
    export ALLOW_MISSING_DEPENDENCIES=true

    # No FOX_RECOVERY_INSTALL_PARTITION: recovery lives inside vendor_boot Entry 1.
fi
