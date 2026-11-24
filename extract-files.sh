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
    if [ -x "${VENDOR_DIR}/extract-files.sh" ] || [ -f "${VENDOR_DIR}/extract-files.sh" ]; then
        echo "Delegating extraction to ${VENDOR_DIR}/extract-files.sh using ${PROPRIETARY_LIST}..."
        exec bash "${VENDOR_DIR}/extract-files.sh" "$@"
    fi
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/lib*/hw/audio.primary.mt6768.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libalsautils.so" "libalsautils-v33.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${PROPRIETARY_LIST}" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
