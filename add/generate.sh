#!/bin/bash
echo "========================="
echo "IN generate.sh $@"
set -xe
ref=$1
dir=/opt/i3-$ref
git clone -b $ref https://github.com/Airblader/i3.git $dir
# for subsequent runs
cd $dir && git pull

echo "EOF generate.sh"
mkdir -p build && cd build

outdir=/usr/local
outdir=/mytarget
test -d $outdir || mkdir -p $outdir

meson --prefix $outdir
echo find1
find -type f -ls

ninja
echo find2
find $outdir -type f -mmin -12

ninja install
echo find3
find $outdir -type f -mmin -12

echo EOF generate.sh
exit 0
