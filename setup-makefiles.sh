#!/bin/bash
#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=poplar
VENDOR=lenovo

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
VENDOR_DIR="${ANDROID_ROOT}/vendor/${VENDOR}/${DEVICE}"
PROPRIETARY_LIST="${VENDOR_DIR}/proprietary-files.txt"

if [ ! -f "${HELPER}" ]; then
    echo "Notice: Unable to find helper script at ${HELPER}"
    if [ -f "${VENDOR_DIR}/setup-makefiles.sh" ]; then
        echo "Delegating makefile generation to ${VENDOR_DIR}/setup-makefiles.sh..."
        exec bash "${VENDOR_DIR}/setup-makefiles.sh" "$@"
    fi
    exit 1
fi
source "${HELPER}"

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

write_makefiles "${PROPRIETARY_LIST}" true

# Finish
write_footers
