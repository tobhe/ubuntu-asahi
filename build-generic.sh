#!/bin/bash
# Check to ensure that, if we're in WSL2, we're using systemd,
# as otherwise the rootfs setup will generate an invalid grub
# config due to the lack of /dev/disk.
if [[ -n "$IS_WSL" || -n "$WSL_DISTRO_NAME" ]]; then
	INIT_SYSTEM=$(ps --no-headers -o comm 1)
	if [[ "$INIT_SYSTEM" != "systemd" ]]; then
		echo "WSL detected, but init system is not systemd. Please use subsystemctl to run systemd."
		exit 1
	fi
fi

if [[ "${EUID:-$(id -u)}" != 0 ]]; then
	echo "This script must be run as root."
	exit 1
fi

set -xe

mkdir -p build
cd build

../scripts/01-build-base-rootfs.sh
../scripts/02-setup-rootfs.sh

# ../scripts/live/03-setup-efi-img.sh
# ../scripts/live/04-setup-live-rootfs.sh
# ../scripts/live/05-setup-pool.sh
# ../scripts/live/06-build-live-image.sh
# 
../scripts/disk/03-setup-disk-rootfs.sh
../scripts/disk/04-build-disk-image.sh
