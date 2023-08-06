#!/bin/bash

# Colours
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
green='\033[32m'
nocol='\033[0m'

# Params
KERNEL_DEFCONFIG=sdm660-perf_defconfig
ANYKERNEL3_DIR=$PWD/AnyKernel3/
FINAL_KERNEL_ZIP=Alpha-X00T-$(date '+%Y%m%d').zip
BUILD_START=$(date +"%s")

echo ""
# Compilation
echo -e "$yellow Compiling the kernel $nocol"

export ARCH=arm64
export CROSS_COMPILE=${PWD}/gcc/bin/aarch64-linux-android-

make O=out clean
make O=out mrproper
make O=out $KERNEL_DEFCONFIG
make O=out -j$(nproc --all)

echo ""
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue ########## Kernel Compiled in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds ##########$nocol"
echo ""

# Anykernel 3 time!!
echo "**** Verifying AnyKernel3 Directory ****"
ls $ANYKERNEL3_DIR
echo "**** Removing leftovers ****"
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP

echo "**** Copying Image.gz-dtb ****"
cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL3_DIR/

echo "**** Time to zip up! ****"
cd $ANYKERNEL3_DIR/
zip -r9 "../$FINAL_KERNEL_ZIP" * -x README $FINAL_KERNEL_ZIP

echo "**** Done, here is your sha1 ****"
cd ..
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf out/

sha1sum $FINAL_KERNEL_ZIP