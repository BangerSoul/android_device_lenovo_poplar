#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export RECOVERY_FRAMEWORK=twrp
exec bash "$script_dir/build-common.sh" "$@"
