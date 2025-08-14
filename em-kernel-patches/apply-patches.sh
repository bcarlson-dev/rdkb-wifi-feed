#!/bin/bash

# Usage: apply-patches.sh <target_dir> <patch_dir>
TARGET_DIR="$1"
PATCH_DIR="$2"

exec 1>&2

if [ ! -d "$TARGET_DIR" ] || [ ! -d "$PATCH_DIR" ]; then
    echo "Error: Invalid directories provided"
    exit 1
fi

echo "Applying patches from $PATCH_DIR to $TARGET_DIR"

# Find all patch files and apply them
for patch_file in $(find "$PATCH_DIR" -name "*.patch" | sort); do
    echo "Checking patch: $(basename $patch_file)"
    
    # Try to apply the patch (dry-run first)
    if patch --dry-run --forward -p1 -d "$TARGET_DIR" < "$patch_file" >/dev/null 2>&1; then
        echo "  Applying: $(basename $patch_file)"
        patch --forward -p1 -d "$TARGET_DIR" < "$patch_file"
        if [ $? -eq 0 ]; then
            echo "  ✓ Successfully applied"
        else
            echo "  ✗ Failed to apply"
        fi
    else
        echo "  → Skipping (already applied or doesn't apply)"
    fi
done