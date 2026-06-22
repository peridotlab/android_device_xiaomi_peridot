#!/bin/bash

DEVICE_PATH="device/xiaomi/peridot"

apply_patch() {
    local dir="$1"
    local patch="$2"
    local subject="$3"

    if [ ! -d "$dir" ]; then
        echo "[peridot] ERROR: $dir not found, cannot apply $patch"
        return
    fi

    cd "$dir" || return

    if git log --oneline | grep -q "$subject"; then
        cd - > /dev/null || return
        return
    fi

    if ! git am --ignore-whitespace "$DEVICE_PATH/patches/$patch" 2>/tmp/peridot_patch_err; then
        git am --abort 2>/dev/null || true
        echo "[peridot] ERROR: Failed to apply $patch"
        cat /tmp/peridot_patch_err
        rm -f /tmp/peridot_patch_err
    fi

    cd - > /dev/null || return
}

apply_patch "vendor/qcom/opensource/agm" "0001-agm-convert-bringup-libraries-to-soong.patch" "agm: Convert bringup libraries to Soong"
apply_patch "system/media" "0002-audio-route-add-libaudioroute-v34.patch" "audio_route: Add libaudioroute-v34"
