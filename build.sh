#!/bin/sh

KERNEL_VERSION=6.1.159
TOYBOX_VERSION=0.8.13

# Some variables for directories

BUILD_ENV_DIR=$PWD # BUILD_ENV_DIR

cd configs
CONFIG_DIR=$PWD # CONFIG_DIR
cd $BUILD_ENV_DIR

mkdir -p src
mkdir -p output/initrd

cd output
OUTPUT_DIR=$PWD # OUTPUT_DIR
cd $BUILD_ENV_DIR

cd $OUTPUT_DIR/initrd
INITRD_DIR=$PWD # INITRD_DIR
cd $BUILD_ENV_DIR

cd src
SOURCE_DIR=$PWD # SOURCE_DIR
cd $BUILD_ENV_DIR

# // Download the source code of packages to build
cd $SOURCE_DIR

wget https://landley.net/toybox/downloads/toybox-$TOYBOX_VERSION.tar.gz
tar xf toybox-$TOYBOX_VERSION.tar.gz

wget https://musl.cc/x86_64-linux-musl-cross.tgz
tar -xf x86_64-linux-musl-cross.tgz

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
tar -xf linux-$KERNEL_VERSION.tar.xz

cd $INITRD_DIR
mkdir dev sys etc proc usr lib lib64 usr/share usr/lib usr/lib64 etc/init.d
cd $SOURCE_DIR

# \\

# // Setting up the x86_64-linux-musl cross compiling environment

cd x86_64-linux-musl-cross

# Copying shared libraries to rootfs

cp x86_64-linux-musl/lib/libc.so $INITRD_DIR/lib/ld-musl-x86_64.so.1

cd $SOURCE_DIR

# \\

# // Toybox

cd toybox-$TOYBOX_VERSION

make defconfig

cp $CONFIG_DIR/toybox.config .config

yes "" | make oldconfig

make CROSS_COMPILE=$SOURCE_DIR/x86_64-linux-musl-cross/bin/x86_64-linux-musl- || exit 1
make PREFIX=$INITRD_DIR install

cd $SOURCE_DIR

# \\

# // initrd

cd $INITRD_DIR

ln -s sbin/init init

cd etc/init.d

echo '#!/bin/sh' > rcS
echo 'mount -t sysfs /sys /sys' >> rcS
echo 'mount -t proc /proc /proc' >> rcS
echo 'mount -t devtmpfs /dev /dev' >> rcS

chmod +x rcS

cd $INITRD_DIR

find . | cpio -o -H newc > $OUTPUT_DIR/init.cpio

cd $SOURCE_DIR

# \\

# // Kernel

cd linux-$KERNEL_VERSION

make defconfig

# Change the kernel configurations

./scripts/config --set-val CONFIG_FB y
./scripts/config --set-val CONFIG_DRM_BOCHS y
./scripts/config --set-val CONFIG_DRM_FBDEV_EMULATION y
./scripts/config --set-val CONFIG_LOGO y

# End of changing kernel configurations

yes "" | make oldconfig
make || exit 1

# Create iso image to be written to a thumb drive
make isoimage FDARGS="initrd=/init.cpio" FDINITRD=$OUTPUT_DIR/init.cpio

cp arch/x86/boot/bzImage $OUTPUT_DIR/bzImage
cp arch/x86/boot/image.iso $OUTPUT_DIR/image.iso

# \\

cd $BUILD_ENV_DIR # Get out of src folder (END)

qemu-system-x86_64 -kernel $OUTPUT_DIR/bzImage -initrd $OUTPUT_DIR/init.cpio
