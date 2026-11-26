#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Device-specific OrangeFox setup for Lenovo Tab TB311FU (poplar).

FDEVICE="poplar"

if [[ "${1:-}" == "$FDEVICE" || "${FOX_BUILD_DEVICE:-}" == "$FDEVICE" ]]; then
    export FOX_BUILD_DEVICE="$FDEVICE"
    export TARGET_DEVICE="$FDEVICE"
    export TARGET_DEVICE_ALT="TB311FU,poplar_row_wifi"
    export FOX_TARGET_DEVICES="poplar,TB311FU,poplar_row_wifi"

    # The device uses dynamic logical partitions and Virtual A/B OTA.
    export OF_AB_DEVICE=1
    export OF_VIRTUAL_AB_DEVICE=1
    export OF_ENABLE_LPTOOLS=1

    # No FOX_RECOVERY_INSTALL_PARTITION is set: recovery lives in vendor_boot.
fi
