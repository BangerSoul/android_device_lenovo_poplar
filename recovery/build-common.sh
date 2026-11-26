#!/usr/bin/env bash
# Shared build driver for this device's TWRP and OrangeFox vendor_boot builds.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: recovery/build-twrp.sh --lunch PRODUCT [options]
       recovery/build-orangefox.sh --lunch PRODUCT [options]

Run from the root of a compatible Android/TWRP/OrangeFox source checkout,
with this device tree at device/lenovo/poplar.

Options:
  --lunch PRODUCT       Required lunch target for the selected recovery tree.
  --jobs N              Parallel build jobs (default: nproc, or 1 if unavailable).
  --target TARGET       Build target (only vendorbootimage is supported).
  --setup-script FILE   Source an additional device setup script before lunch.
  --clean               Run installclean before building.
  --dry-run             Print the resolved build plan without running a build.
  -h, --help            Show this help.

A dedicated recovery partition does not exist on TB311FU. This builder only
builds vendorbootimage; it never flashes images or runs fastboot commands.
EOF
}

fail() { printf 'error: %s\n' "$*" >&2; exit 2; }

framework="${RECOVERY_FRAMEWORK:-}"
[[ "$framework" == twrp || "$framework" == orangefox ]] || fail "RECOVERY_FRAMEWORK must be twrp or orangefox (use the provided wrapper)"
lunch_target=""
jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')"
build_target="vendorbootimage"
setup_script=""
clean=false
dry_run=false

while (($#)); do
    case "$1" in
        --lunch) (($# >= 2)) || fail "--lunch requires a value"; lunch_target="$2"; shift 2 ;;
        --jobs) (($# >= 2)) || fail "--jobs requires a value"; jobs="$2"; shift 2 ;;
        --target) (($# >= 2)) || fail "--target requires a value"; build_target="$2"; shift 2 ;;
        --setup-script) (($# >= 2)) || fail "--setup-script requires a value"; setup_script="$2"; shift 2 ;;
        --clean) clean=true; shift ;;
        --dry-run) dry_run=true; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; (($# == 0)) || fail "unexpected positional arguments: $*" ;;
        *) fail "unknown option: $1" ;;
    esac
done

[[ -n "$lunch_target" ]] || fail "--lunch is required; choose a product defined by your recovery source tree"
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || fail "--jobs must be a positive integer"
[[ "$build_target" == vendorbootimage ]] || fail "only vendorbootimage is valid for this device (no recovery partition)"
[[ -f build/envsetup.sh ]] || fail "run this script from the root of an Android source checkout (build/envsetup.sh not found)"
[[ -d device/lenovo/poplar ]] || fail "device tree must be at device/lenovo/poplar"
[[ -f device/lenovo/poplar/recovery/BoardConfigRecovery.mk ]] || fail "recovery configuration is missing"

if [[ "$framework" == orangefox && -z "$setup_script" ]]; then
    setup_script="device/lenovo/poplar/recovery/orangefox/vendorsetup.sh"
fi
if [[ -n "$setup_script" && ! -f "$setup_script" ]]; then
    fail "setup script not found: $setup_script"
fi

printf 'Recovery framework: %s\nLunch target: %s\nBuild target: %s\nJobs: %s\n' \
    "$framework" "$lunch_target" "$build_target" "$jobs"
[[ -z "$setup_script" ]] || printf 'Setup script: %s\n' "$setup_script"
[[ "$clean" == false ]] || printf 'Pre-build: installclean\n'

if [[ "$dry_run" == true ]]; then
    printf 'Dry run: source build/envsetup.sh; set RECOVERY_VARIANT=%s; lunch %s; m -j%s %s\n' \
        "$framework" "$lunch_target" "$jobs" "$build_target"
    exit 0
fi

# Build environment and project setup must be loaded in this shell.
source build/envsetup.sh
export RECOVERY_VARIANT="$framework"
if [[ -n "$setup_script" ]]; then
    # OrangeFox device setup scripts conventionally accept the device codename.
    source "$setup_script" poplar
fi
lunch "$lunch_target"

if [[ "$clean" == true ]]; then
    m installclean
fi
m -j"$jobs" "$build_target"

printf '\nBuild finished. Inspect the produced vendor_boot image and ramdisk layout before device testing.\n'
