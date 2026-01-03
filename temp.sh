#!/bin/sh

KERNEL_VERSION=6.1.159
TOYBOX_VERSION=0.8.13

BUILD_ENV_DIR=$PWD # BUILD_ENV_DIR

cd configs
CONFIG_DIR=$PWD # CONFIG_DIR
cd ..

mkdir -p src
mkdir -p output/initrd

cd output
OUTPUT_DIR=$PWD # OUTPUT_DIR
cd ..

cd $OUTPUT_DIR/initrd
echo $OUTPUT_DIR/initrd
INITRD_DIR=$PWD # INITRD_DIR
cd 

cd src
SOURCE_DIR=$PWD # SOURCE_DIR
