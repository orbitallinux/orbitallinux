#!/bin/sh

KERNEL_VERSION=6.1.159
TOYBOX_VERSION=0.8.13

mkdir -p src
cd src

# Toybox

wget https://landley.net/toybox/downloads/toybox-$TOYBOX_VERSION.tar.gz
tar xf toybox-$TOYBOX_VERSION.tar.gz

cd toybox-$TOYBOX_VERSION

mkdir -p "../../output/initrd"

make defconfig
make || exit
make PREFIX=../../output/initrd install

cd ..

# initrd

cd ../output/initrd

echo '#!/bin/sh' > init
#echo 'mount -t sysfs sysfs /sys' >> init
#echo 'mount -t proc proc /proc' >> init
#echo 'mount -t devtmpfs udev /dev' >> init
#echo 'sysctl -w kernel.printk="2 4 1 7"'
echo '/bin/sh' >> init

chmod +x init

find . | cpio -o -H newc > ../init.cpio

cd ../../src

# Kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
tar -xf linux-$KERNEL_VERSION.tar.xz
cd linux-$KERNEL_VERSION

make defconfig

# Change the kernel configurations

./scripts/config --set-val CONFIG_FB y
./scripts/config --set-val CONFIG_DRM_BOCHS y
./scripts/config --set-val CONFIG_DRM_FBDEV_EMULATION y
./scripts/config --set-val CONFIG_LOGO y

# End of changing kernel configurations

make || exit

cp arch/x86/boot/bzImage ../../output/bzImage

cd ..

qemu-system-x86_64 -kernel ../output/bzImage -initrd ../output/init.cpio
