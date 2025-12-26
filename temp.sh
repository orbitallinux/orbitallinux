#!/bin/sh

KERNEL_VERSION=6.1.159
BUSYBOX_VERSION=snapshot

# initrd

cd src

cd busybox

mkdir -p "../../output/initrd"

make CONFIG_PREFIX=../../output/initrd install
