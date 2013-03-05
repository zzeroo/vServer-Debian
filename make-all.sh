#!/bin/sh

# ISO entpacken
[ -f debian-wheezy-DI-rc1-amd64-netinst.iso ] || cp /home/smueller/Downloads/ISOs/debian-wheezy-DI-rc1-amd64-netinst.iso .
mkdir -p loopdir
mount -o loop debian-wheezy-DI-rc1-amd64-netinst.iso loopdir
[ -d cd ] && rm -rf cd
mkdir cd
rsync -a -H --exclude=TRANS.TBL loopdir/ cd
umount loopdir

# preseed.cfg einbinden
[ -f preseed.cfg-vserver ] || wget https://raw.github.com/zzeroo/vServer-Debian/master/preseed.cfg-vserver
mkdir irmod
cd irmod
gzip -d < ../cd/install.amd/initrd.gz |       cpio --extract --verbose --make-directories --no-absolute-filenames
cp ../preseed.cfg-vserver preseed.cfg
find . | cpio -H newc --create --verbose |       gzip -9 > ../cd/install.amd/initrd.gz 
cd ../
rm -fr irmod/

# Firmware einbinden
FWTMP=$(pwd)/d-i_firmware
rm -rf $FWTMP
mkdir  -p $FWTMP/firmware
cd $FWTMP
[ -f firmware.tar.gz ] || wget http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/wheezy/current/firmware.tar.gz
[ -d firmware ] || tar -C firmware -zxf firmware.tar.gz
pax -x sv4cpio -s'%firmware%/firmware%' -w firmware | gzip -c >firmware.cpio.gz
cd $FWTMP/../cd/install.amd
cp -p initrd.gz initrd.gz.orig
cat initrd.gz.orig $FWTMP/firmware.cpio.gz > initrd.gz
cd $FWTMP/..
wget https://raw.github.com/zzeroo/vServer-Debian/master/isolinux/isolinux.cfg -O cd/isolinux/isolinux.cfg 
wget https://raw.github.com/zzeroo/vServer-Debian/master/isolinux/txt.cfg -O cd/isolinux/txt.cfg 
wget https://raw.github.com/zzeroo/vServer-Debian/master/isolinux/splash.png -O cd/isolinux/splash.png 
cd cd
md5sum `find -follow -type f` > md5sum.txt
cd ..


echo "genisoimage -o vserver-debian-testing-amd64.iso -r -J     -no-emul-boot -boot-load-size 4      -boot-info-table -b isolinux/isolinux.bin     -c isolinux/boot.cat ./cd"
echo "dvd+rw-format -force /dev/sr0"
echo "growisofs -Z /dev/sr0=vserver-debian-testing-amd64.iso"
echo "cp vserver-debian-testing-amd64.iso /tmp/"


