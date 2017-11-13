#!/bin/bash
export KBUILD_BUILD_USER="Shekhawat2"
export KBUILD_BUILD_HOST="Builder"
export CROSS_COMPILE=/home/anansingh17/linaro7/bin/aarch64-linux-gnu-
export ARCH=arm64
export SUBARCH=arm64
make clean && make mrproper
rm -rf ../anykernel/dt.img
rm -rf ../anykernel/modules/wlan.ko
rm -rf ../anykernel/zImage
ccache -c
BUILD_START=$(date +"%s")
KERNEL_DIR=$PWD
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
blue='\033[0;34m' cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
echo "Starting"
make KCUF_tomato_defconfig
echo "Making"
make -j8
echo "Making dt.img"
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
echo "Done"
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
BUILD_TIME=$(date +"%Y%m%d-%T")
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo "Movings Files"
cd ../anykernel
git reset --hard HEAD
git checkout tomatoo
mv $KERNEL_DIR/arch/arm64/boot/Image zImage
mv $KERNEL_DIR/arch/arm64/boot/dt.img dt.img
mv $KERNEL_DIR/drivers/staging/prima/wlan.ko modules/wlan.ko
cp $KERNEL_DIR/spectrum/init.spectrum.rc ramdisk/init.spectrum.rc
cp $KERNEL_DIR/spectrum/init.spectrum.sh ramdisk/init.spectrum.sh
echo "Making Zip"
zip -r KCUF-O-$BUILD_TIME *
cd ..
mv anykernel/KCUF-O-$BUILD_TIME.zip kernel/KCUF-O-$BUILD_TIME.zip
gdrive upload kernel/KCUF-O-$BUILD_TIME.zip
echo "Uploaded to Gdrive"
cd kcuf
