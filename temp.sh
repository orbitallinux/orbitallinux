#!/bin/sh

KERNEL_VERSION=6.1.159
TOYBOX_VERSION=0.8.13

mkdir src
cd src

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
tar xf linux-$KERNEL_VERSION.tar.xz

wget https://landley.net/toybox/downloads/toybox-$TOYBOX_VERSION.tar.gz
tar xf toybox-$TOYBOX_VERSION.tar.gz
