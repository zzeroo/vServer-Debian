#!/bin/sh

FWTMP=/tmp/d-i_firmware
rm -rf $FWTMP
mkdir  -p $FWTMP/firmware
cd $FWTMP
wget http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/wheezy/current/firmware.tar.gz
tar -C firmware -zxf firmware.tar.gz
pax -x sv4cpio -s'%firmware%/firmware%' -w firmware | gzip -c >firmware.cpio.gz
cd to the directory where you have your initrd
cd /tmp/cd/install.amd/
[ -f initrd.gz.orig ] || cp -p initrd.gz initrd.gz.orig
cat initrd.gz.orig $FWTMP/firmware.cpio.gz > initrd.gz
cd ..
