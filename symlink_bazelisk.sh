#!/bin/bash

BAZELISK="$HOME/tinder_toolchain/bazelisk"
BAZELISK_SYMLINK="/usr/local/bin/bazelisk"
if [ -f "$BAZELISK" ] && [ ! -L ${BAZELISK_SYMLINK} ]; then
    echo "Creating bazelisk symlink -- please provide password for 'sudo' if needed."
    sudo ln -sf "$BAZELISK" "$BAZELISK_SYMLINK"
fi
