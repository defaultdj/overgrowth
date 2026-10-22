#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Build (and optionally run) Overgrowth natively on Arch Linux.

Usage:
  Tools/build_arch_linux.sh [--data-dir GAME_ROOT] [--run] [-- GAME_ARGS...]

Options:
  --data-dir PATH  Installed Overgrowth directory containing Data/.
                   May also be set with OVERGROWTH_DATA_DIR.
  --run            Launch the game after a successful build.
  --help           Show this help.

The repository contains source and development data, not the commercial game
assets. A binary can be built without those assets, but the original game needs
a licensed game-data directory (or a complete total conversion).
EOF
}

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${OVERGROWTH_BUILD_DIR:-${repo_root}/Build}"
data_dir="${OVERGROWTH_DATA_DIR:-}"
jobs="${OVERGROWTH_BUILD_JOBS:-}"
run_after_build=0
runtime_args=()

while (($#)); do
    case "$1" in
        --data-dir)
            if (($# < 2)); then
                echo "error: --data-dir needs a path" >&2
                usage >&2
                exit 2
            fi
            data_dir="$2"
            shift 2
            ;;
        --run)
            run_after_build=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --)
            shift
            runtime_args=("$@")
            break
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if ! command -v cmake >/dev/null 2>&1; then
    echo "error: CMake is missing. Install it with: sudo pacman -S cmake" >&2
    exit 1
fi
if ! command -v pkg-config >/dev/null 2>&1; then
    echo "error: pkg-config is missing. On Arch, install pkgconf: sudo pacman -S pkgconf" >&2
    exit 1
fi

if [[ -z "$jobs" ]]; then
    jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')"
fi
if [[ ! "$jobs" =~ ^[1-9][0-9]*$ ]]; then
    echo "error: OVERGROWTH_BUILD_JOBS must be a positive integer (got '$jobs')" >&2
    exit 2
fi

if [[ "$build_dir" != /* ]]; then
    build_dir="${repo_root}/${build_dir}"
fi

if [[ -n "$data_dir" ]]; then
    if [[ ! -d "$data_dir/Data" ]]; then
        echo "error: '$data_dir' is not a game root containing Data/" >&2
        exit 2
    fi
    data_dir="$(cd -- "$data_dir" && pwd)"
else
    echo "note: no game-data directory supplied; building only. The source checkout does not include the commercial assets."
fi

cmake -S "${repo_root}/Projects" -B "$build_dir" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_OVERGROWTH=ON \
    -DBUILD_OGDA=OFF \
    -DENABLE_RAD_TELEMETRY=OFF \
    -DENABLE_STEAMWORKS=OFF \
    "-DAUX_DATA=${data_dir}"

cmake --build "$build_dir" --parallel "$jobs"

game_bin="${build_dir}/Overgrowth.bin.x86_64"
if [[ ! -x "$game_bin" ]]; then
    echo "error: expected executable was not produced: $game_bin" >&2
    exit 1
fi

printf '\nBuild succeeded. Run with:\n  %q\n' "$game_bin"
if ((run_after_build)); then
    if [[ -z "$data_dir" ]]; then
        echo "warning: starting without a retail data directory; the game may stop with missing-asset errors." >&2
    fi
    exec "$game_bin" "${runtime_args[@]}"
fi
