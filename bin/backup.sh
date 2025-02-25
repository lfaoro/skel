#!/usr/bin/env bash
set -e

function isInstalled() {
    # rsync must be installed
    if [ -z "$(which "$1")" ]; then
        echo "Error: $1 is not installed"
        read -rp "Press Enter to exit..."
        exit 1
    fi
}

# make sure our deps are installed
isInstalled "rsync"
isInstalled "cryptsetup"

# add validation for critical operations
function validateOperation() {
    if [ $? -ne 0 ]; then
        echo "error: operation failed - $1"
        exit 1
    fi
}

DEVICE="/dev/disk/by-id/usb-USB_SanDisk_3.2Gen1_04011e3cc7cd1e365a7e3c66015c0c3c2c0943d3f168f947bd544f65fb853670fa83000000000000000000003f51c6b1ff0c6e18835581079d2d2b82-0:0"
# add safety check for non-empty device path
[ -z "$DEVICE" ] && { echo "error: device path not configured"; exit 1; }

# improve device validation
if [[ ! -e "$DEVICE" ]]; then
    echo "error: device $DEVICE does not exist"
    exit 1
fi

MOUNT_PATH="backup"
# add quotes to prevent path injection
if [[ ! -d "/$MOUNT_PATH" ]]; then
    sudo mkdir -p "/$MOUNT_PATH" || validateOperation "failed to create mount directory"
    echo "mounting $DEVICE on /$MOUNT_PATH"
    
    # add luksOpen validation
    sudo cryptsetup luksOpen "$DEVICE" "$MOUNT_PATH" || validateOperation "luks open failed"
    sudo mount "/dev/mapper/$MOUNT_PATH" "/$MOUNT_PATH" || validateOperation "mount failed"
    sudo chown -R "$(whoami):" "/$MOUNT_PATH"
fi

# improve rsync commands:
# 1. add --mkpath for destination directory creation
# 2. use safer exclusion syntax
# 3. add explicit error handling
RSYNC_EXCLUDES=(
    --exclude='lost+found'
    --exclude='*.ova'
    --exclude='*.iso'
    --exclude='*.qcow2'
    --exclude='*.log'
    --exclude='*.vmdk'
    --exclude='**/cache'
    --exclude='**/.cache'
    --exclude='**/vendor'
    --exclude='work/fastboot'
    --exclude='**/.git'
)

# Add include patterns for M user
RSYNC_INCLUDES=(
    --include='work/***'
)

if ! rsync -avhP --mkpath --delete --delete-excluded --force --stats \
    "${RSYNC_EXCLUDES[@]}" \
    "${RSYNC_INCLUDES[@]}" \
    --exclude='*' \
    -- \
    "$HOME/" "/$MOUNT_PATH/$USER"; then
    echo "warning: backup completed with errors"
fi

if ! sudo umount --force "/$MOUNT_PATH"; then
    echo "error: failed to unmount /$MOUNT_PATH"
    exit 1
fi

if ! sudo cryptsetup luksClose "/dev/mapper/$MOUNT_PATH"; then
    echo "error: failed to close luks device"
    exit 1
fi

if ! sudo udisksctl power-off -b "$DEVICE"; then
    echo "error: failed to power off device"
    exit 1
fi
