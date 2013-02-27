#!/bin/sh

[ -z $1 ] && ISO=debian-testing-amd64-CD-1.iso

cd /tmp
mkdir -p loopdir
mount -o loop $ISO loopdir
[ -d cd ] && rm -rf cd
mkdir cd
echo "rsync files to folder ./cd"
rsync -a -H --exclude=TRANS.TBL loopdir/ cd
umount loopdir

