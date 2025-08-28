#!/bin/bash

exec 1>&2

PATCHES_DIR=$(dirname "$(realpath "$0")")/custom-patches

if [ ! -d "$PATCHES_DIR" ]; then
    echo "Error: Patches directory '$PATCHES_DIR' not found"
    exit 1
fi

MTK_FEEDS_DIR=$(pwd)/../mtk-openwrt-feeds
if [ ! -d "$MTK_FEEDS_DIR" ]; then
    echo "Error: mtk-openwrt-feeds directory not found"
    exit 1
fi
KERNEL_PATCHES_DIR="$MTK_FEEDS_DIR/autobuild/unified/filogic/mac80211/24.10/files/package/kernel"
if [ ! -d "$KERNEL_PATCHES_DIR" ]; then
    echo "Error: Kernel patches directory not found"
    exit 1
fi

# For each folder in the PATCHES_DIR, copy its contents to the corresponding location in the KERNEL_PATCHES_DIR
for dir in "$PATCHES_DIR"/*/; do
    dir_name=$(basename "$dir")
    DEST_DIR="$KERNEL_PATCHES_DIR"
    case "$dir_name" in
        "mt76")
            DEST_DIR="$KERNEL_PATCHES_DIR/mt76/patches"
            ;;
        "mac80211")
            DEST_DIR="$KERNEL_PATCHES_DIR/mac80211/patches/subsys"
            ;;
        *)
            echo "Warning: Unknown directory '$dir_name'. Skipping kernel patch copy."
            continue
            ;;
    esac

    if [ ! -d "$DEST_DIR" ]; then
        echo "Error: Destination directory '$DEST_DIR' does not exist"
        continue
    fi
    echo "Copying patches from '$dir' to '$DEST_DIR'"
    cp -r "$dir"/* "$DEST_DIR"
done