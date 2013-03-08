#!/bin/sh
ROOTDIR=$(pwd)

echo "<<< extracting cd <<<"
mkdir -p loopdir
mount -o loop debian-wheezy-DI-rc1-amd64-netinst.iso loopdir/
[ -d cd ] && rm -rf cd
mkdir cd
rsync -a -H --exclude=TRANS.TBL loopdir/ cd
umount loopdir

echo "<<< patch initrd <<<"
[ -d irmod ] && rm -rf irmod 
mkdir irmod
cd irmod
gzip -d < ../cd/install.amd/initrd.gz |       cpio --extract --verbose --make-directories --no-absolute-filenames
cp ../preseed.cfg-vserver preseed.cfg
find . | cpio -H newc --create --verbose |       gzip -9 > ../cd/install.amd/initrd.gz 
cd ../
rm -fr irmod/

echo "<<< firmware einbinden <<<"
FWTMP=$(pwd)/d-i_firmware
rm -rf $FWTMP
mkdir  -p $FWTMP/firmware
cd $FWTMP
wget http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/wheezy/current/firmware.tar.gz
tar -C firmware -zxf firmware.tar.gz
pax -x sv4cpio -s'%firmware%/firmware%' -w firmware | gzip -c >firmware.cpio.gz
cd $FWTMP/../cd/install.amd
cp -p initrd.gz initrd.gz.orig
cat initrd.gz.orig $FWTMP/firmware.cpio.gz > initrd.gz
cd ..

echo "<<< splash screen <<<"
cd $ROOTDIR
wget https://raw.github.com/zzeroo/vServer-Debian/master/isolinux/isolinux.cfg -O cd/isolinux/isolinux.cfg 
wget https://raw.github.com/zzeroo/vServer-Debian/master/isolinux/txt.cfg -O cd/isolinux/txt.cfg 
wget https://raw.github.com/zzeroo/vServer-Debian/master/isolinux/splash.png -O cd/isolinux/splash.png 

echo "<<< md5sum <<<"
cd cd
md5sum `find -follow -type f` > md5sum.txt
cd ..

echo "<<< iso erstellen <<<"
genisoimage -o vserver-debian-testing-amd64.iso -r -J     -no-emul-boot -boot-load-size 4      -boot-info-table -b isolinux/isolinux.bin     -c isolinux/boot.cat ./cd
