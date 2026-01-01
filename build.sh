#!/bin/sh

KERNEL_VERSION=6.1.159
TOYBOX_VERSION=0.8.13
MUSL_LIBC_VERSION=1.2.5

mkdir -p src
cd src

wget https://landley.net/toybox/downloads/toybox-$TOYBOX_VERSION.tar.gz
tar xf toybox-$TOYBOX_VERSION.tar.gz

wget https://musl.libc.org/releases/musl-$MUSL_LIBC_VERSION.tar.gz
tar -xf musl-$MUSL_LIBC_VERSION.tar.gz

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
tar -xf linux-$KERNEL_VERSION.tar.xz

mkdir -p "../output/initrd"

cd ../output/initrd
mkdir dev sys etc proc usr/share usr/lib usr/lib64 etc/init.d lib lib64
cd ../../src

# Musl C library

cd musl-$MUSL_LIBC_VERSION

./configure

make || exit 1

cp lib/libc.so ../../output/initrd/lib/ld-musl-x86_64.so.1

cd ..

# Toybox

cd toybox-$TOYBOX_VERSION

make defconfig

cp ../../.config .config

yes "" | make oldconfig

make LDFLAGS=--static || exit 1
make PREFIX=../../output/initrd install

cd ..

# initrd

cd ../output/initrd

ln -s sbin/init init

cd etc/init.d

echo '#!/bin/sh' > rcS
echo 'mount -t sysfs /sys /sys' >> rcS
echo 'mount -t proc /proc /proc' >> rcS
echo 'mount -t devtmpfs /dev /dev' >> rcS

chmod +x rcS

cd ../..

find . | cpio -o -H newc > ../init.cpio

cd ../../src

# Kernel

cd linux-$KERNEL_VERSION

make defconfig

# Change the kernel configurations

./scripts/config --set-val CONFIG_FB y
./scripts/config --set-val CONFIG_DRM_BOCHS y
./scripts/config --set-val CONFIG_DRM_FBDEV_EMULATION y
./scripts/config --set-val CONFIG_LOGO y

# End of changing kernel configurations

yes "" | make oldconfig
make isoimage FDARGS="initrd=/init.cpio" FDINITRD=../../output/init.cpio || exit 1

#cp arch/x86/boot/bzImage ../../output/bzImage

cp arch/x86/boot/image.iso ../../output/image.iso

cd ..

qemu-system-x86_64 -cdrom ../output/image.iso
