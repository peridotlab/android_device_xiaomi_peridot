#!/bin/bash

DEVICE_PATH="device/xiaomi/peridot"

apply_patch() {
    local dir="$1"
    local patch="$2"
    local subject="$3"
    local top="${ANDROID_BUILD_TOP:-$(gettop)}"
    local target_dir="$top/$dir"
    local patch_path="$top/$DEVICE_PATH/patches/$patch"

    if [ ! -d "$target_dir" ]; then
        echo "[peridot] ERROR: $dir not found, cannot apply $patch"
        return
    fi

    if [ ! -f "$patch_path" ]; then
        echo "[peridot] ERROR: $patch_path not found"
        return
    fi

    if git -C "$target_dir" log --oneline | grep -q "$subject"; then
        return
    fi

    if ! git -C "$target_dir" am --ignore-whitespace "$patch_path" 2>/tmp/peridot_patch_err; then
        git -C "$target_dir" am --abort 2>/dev/null || true
        echo "[peridot] ERROR: Failed to apply $patch"
        cat /tmp/peridot_patch_err
        rm -f /tmp/peridot_patch_err
    fi
}

apply_patch "hardware/qcom-caf/sm8650/audio/agm" "0001-agm-convert-bringup-libraries-to-soong.patch" "agm: Convert bringup libraries to Soong"
apply_patch "system/media" "0002-audio-route-add-libaudioroute-v34.patch" "audio_route: Add libaudioroute-v34"
