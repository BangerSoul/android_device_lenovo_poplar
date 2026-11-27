#!/usr/bin/env bash
# Shared multi-variant recovery builder for Lenovo Tab TB311FU / XT2573-1 (poplar).
# Supports RECOVERY_VARIANT=aosp | twrp | orangefox and outputs vendor_boot.img.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: recovery/build-twrp.sh [options]
       recovery/build-orangefox.sh [options]
       recovery/build-aosp.sh [options]
       RECOVERY_VARIANT=<aosp|twrp|orangefox> recovery/build-common.sh [options]

Run from the root of an AOSP, minimal-manifest-twrp, or OrangeFox source checkout,
with this device tree at device/lenovo/poplar.

Options:
  --variant VARIANT        Recovery variant: aosp, twrp, or orangefox.
  --lunch PRODUCT          Lunch target (default: aosp_poplar-userdebug for aosp,
                           twrp_poplar-eng for twrp/orangefox).
  --jobs N                 Parallel jobs (default: detected online CPU count, or 1).
  --target TARGET          Build target (default/only valid: vendorbootimage).
  --setup-script FILE      Source an additional device setup script before lunch.
  --expect-branch PATH=BRANCH
                           Verify a Git checkout at PATH is on BRANCH; repeatable.
  --allow-missing-vendor   Proceed even if vendor/lenovo/poplar is not checked out
                           (intended for standalone minimal CI/preflight builds).
  --clean                  Run installclean before building.
  --dry-run                Validate inputs/branches and print the planned commands.
  -h, --help               Show this help.
EOF
}

fail() { printf 'error: %s\n' "$*" >&2; exit 2; }

variant="${RECOVERY_VARIANT:-}"
lunch_target=""
jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')"
build_target="vendorbootimage"
setup_script=""
clean=false
dry_run=false
allow_missing_vendor=false
expected_branches=()

while (($#)); do
    case "$1" in
        --variant) (($# >= 2)) || fail "--variant requires a value"; variant="$2"; shift 2 ;;
        --lunch) (($# >= 2)) || fail "--lunch requires a value"; lunch_target="$2"; shift 2 ;;
        --jobs) (($# >= 2)) || fail "--jobs requires a value"; jobs="$2"; shift 2 ;;
        --target) (($# >= 2)) || fail "--target requires a value"; build_target="$2"; shift 2 ;;
        --setup-script) (($# >= 2)) || fail "--setup-script requires a value"; setup_script="$2"; shift 2 ;;
        --expect-branch) (($# >= 2)) || fail "--expect-branch requires PATH=BRANCH"; expected_branches+=("$2"); shift 2 ;;
        --allow-missing-vendor) allow_missing_vendor=true; shift ;;
        --clean) clean=true; shift ;;
        --dry-run) dry_run=true; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; (($# == 0)) || fail "unexpected positional arguments: $*" ;;
        *) fail "unknown option: $1" ;;
    esac
done

case "$variant" in
    aosp|twrp|orangefox) ;;
    *) fail "RECOVERY_VARIANT must be one of: aosp, twrp, orangefox (got '$variant')" ;;
esac

resolve_lunch_target() {
    local target="$1"
    # Android 14 QPR2+ (e.g. android-14.0.0_r67, twrp-14.1) requires <product>-<release>-<variant>.
    if [[ "$target" == *-* && "$target" != *-*-* ]] && grep -q '<product>-<release>-<variant>' build/envsetup.sh 2>/dev/null; then
        local product="${target%%-*}"
        local build_var="${target#*-}"
        local release_cfg="${TARGET_RELEASE:-}"
        if [[ -z "$release_cfg" ]]; then
            if [[ -f build/release/build_config/ap2a.scl ]]; then
                release_cfg="ap2a"
            else
                local scl
                scl="$(find build/release/build_config -maxdepth 1 -name '*.scl' 2>/dev/null | head -n 1 || true)"
                release_cfg="${scl##*/}"
                release_cfg="${release_cfg%.scl}"
            fi
        fi
        if [[ -n "$release_cfg" ]]; then
            target="${product}-${release_cfg}-${build_var}"
        fi
    fi
    printf '%s\n' "$target"
}

if [[ -z "$lunch_target" ]]; then
    if [[ "$variant" == aosp ]]; then
        lunch_target="aosp_poplar-userdebug"
    else
        lunch_target="twrp_poplar-eng"
    fi
fi

lunch_target="$(resolve_lunch_target "$lunch_target")"

[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || fail "--jobs must be a positive integer"
[[ "$build_target" == vendorbootimage ]] || fail "only vendorbootimage is valid for TB311FU (no physical recovery partition)"
[[ -f build/envsetup.sh ]] || fail "run this script from the root of an Android/TWRP/OrangeFox checkout (build/envsetup.sh not found)"
[[ -d device/lenovo/poplar ]] || fail "device tree must be located at device/lenovo/poplar"
[[ -f device/lenovo/poplar/recovery/BoardConfigRecovery.mk ]] || fail "recovery/BoardConfigRecovery.mk is missing"
[[ -f device/lenovo/poplar/recovery.fstab ]] || fail "recovery.fstab is missing"
[[ -f device/lenovo/poplar/recovery/twrp.flags ]] || fail "recovery/twrp.flags is missing"

if [[ ! -f vendor/lenovo/poplar/BoardConfigVendor.mk ]]; then
    if [[ "$allow_missing_vendor" == true ]]; then
        printf 'warning: vendor/lenovo/poplar not present; building without proprietary recovery blobs\n' >&2
    else
        fail "compatible vendor tree missing at vendor/lenovo/poplar (pass --allow-missing-vendor to override)"
    fi
fi

if [[ ! -f kernel/lenovo/poplar/Makefile && ! -f device/lenovo/poplar/prebuilt/Image.gz ]]; then
    fail "provide kernel/lenovo/poplar/Makefile or device/lenovo/poplar/prebuilt/Image.gz"
fi

if [[ "$variant" == orangefox && -z "$setup_script" ]]; then
    setup_script="device/lenovo/poplar/recovery/orangefox/vendorsetup.sh"
fi
if [[ -n "$setup_script" && ! -f "$setup_script" ]]; then
    fail "setup script not found: $setup_script"
fi

for expectation in "${expected_branches[@]}"; do
    [[ "$expectation" == *=* ]] || fail "invalid --expect-branch '$expectation' (expected PATH=BRANCH)"
    tree_path="${expectation%%=*}"
    expected_branch="${expectation#*=}"
    [[ -n "$tree_path" && -n "$expected_branch" ]] || fail "invalid --expect-branch '$expectation'"
    [[ -d "$tree_path" ]] || fail "checkout path not found: $tree_path"
    [[ -d "$tree_path/.git" || -f "$tree_path/.git" ]] || fail "not a Git checkout: $tree_path"
    actual_branch="$(git -C "$tree_path" branch --show-current)" || fail "cannot read branch for $tree_path"
    [[ -n "$actual_branch" ]] || fail "$tree_path is in detached-HEAD state; check out '$expected_branch'"
    [[ "$actual_branch" == "$expected_branch" ]] || fail "$tree_path is on '$actual_branch', expected '$expected_branch'"
done

printf 'Recovery variant: %s\nLunch target: %s\nBuild target: %s\nJobs: %s\n' \
    "$variant" "$lunch_target" "$build_target" "$jobs"
[[ -z "$setup_script" ]] || printf 'Setup script: %s\n' "$setup_script"
for expectation in "${expected_branches[@]}"; do
    printf 'Verified branch: %s (%s)\n' "${expectation#*=}" "${expectation%%=*}"
done
[[ "$clean" == false ]] || printf 'Pre-build: installclean\n'

if [[ "$dry_run" == true ]]; then
    printf 'Dry run: source build/envsetup.sh; export RECOVERY_VARIANT=%s ALLOW_MISSING_DEPENDENCIES=true LC_ALL=C; lunch %s; m -j%s RECOVERY_VARIANT=%s %s\n' \
        "$variant" "$lunch_target" "$jobs" "$variant" "$build_target"
    exit 0
fi

export LC_ALL=C
export RECOVERY_VARIANT="$variant"
export ALLOW_MISSING_DEPENDENCIES=true
if [[ "$variant" == orangefox ]]; then
    export FOX_BUILD_TYPE="${FOX_BUILD_TYPE:-Unofficial}"
fi

set +e +u
set +o pipefail
source build/envsetup.sh
if [[ -n "$setup_script" ]]; then
    source "$setup_script" poplar
fi
lunch "$lunch_target"
lunch_rc=$?
set -euo pipefail
((lunch_rc == 0)) || fail "lunch failed for '$lunch_target' (exit $lunch_rc)"

if [[ "$clean" == true ]]; then
    m installclean
fi
m -j"$jobs" RECOVERY_VARIANT="$variant" "$build_target"

out_img="${OUT:-out/target/product/poplar}/vendor_boot.img"
if [[ -f "$out_img" ]]; then
    sha256sum "$out_img"
    unpack_bin="${ANDROID_HOST_OUT:-out/host/linux-x86}/bin/unpack_bootimg"
    if [[ -x "$unpack_bin" ]]; then
        tmp_unpack="$(mktemp -d)"
        "$unpack_bin" --boot_img "$out_img" --out "$tmp_unpack"
        rm -rf "$tmp_unpack"
    fi
fi

printf '\nBuild finished (%s). Validate display rotation, touch input, FBE decrypt, ADB/MTP, and fastbootd before release.\n' "$variant"
