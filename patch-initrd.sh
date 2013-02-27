#!/bin/sh

cd /tmp
wget https://raw.github.com/zzeroo/vServer-Debian/master/preseed.cfg-vserver
mkdir irmod
cd irmod
gzip -d < ../cd/install.amd/initrd.gz | \
      cpio --extract --verbose --make-directories --no-absolute-filenames
cp ../preseed.cfg-vserver preseed.cfg
find . | cpio -H newc --create --verbose | \
      gzip -9 > ../cd/install.amd/initrd.gz 
cd ../
rm -fr irmod/
