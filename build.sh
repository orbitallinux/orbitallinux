#!/bin/sh

KERNEL_VERSION=6.1.159
BUSYBOX_VERSION=snapshot

mkdir -p src
cd src

# Kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
tar -xf linux-$KERNEL_VERSION.tar.xz
cd linux-$KERNEL_VERSION

make defconfig
make || exit

cp arch/x86/boot/bzImage ../../output/bzImage

cd ..

# Busybox

wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
cd busybox-$BUSYBOX_VERSION || cd busybox

make defconfig
sed 's/^.*CONFIG_STATIC[^_].*$/CONFIG_STATIC=y/g' -i .config
sed 's/^.*CONFIG_TC[^_].*$/CONFIG_TC=n/g' -i .config
make || exit

# initrd

mkdir -p ../../output/initrd
make CONFIG_PREFIX=../../output/initrd install

cd ../../output/initrd

echo '#!/bin/sh' > init
#echo 'mount -t sysfs sysfs /sys' >> init
#echo 'mount -t proc proc /proc' >> init
#echo 'mount -t devtmpfs udev /dev' >> init
#echo 'sysctl -w kernel.printk="2 4 1 7"'
echo '/bin/sh' >> init

find . | cpio -o -H newc > ../initrd.img

cd ..

qemu-system-x86_64 -kernel bzImage -initrd initrd.img
