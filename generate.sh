#!/bin/bash -xe
ref=$1
dir=/opt/i3-$ref
git clone -b $ref https://github.com/Airblader/i3.git $dir
# for subsequent runs
cd $dir && git pull
cd $dir &&
  autoreconf --force --install \
  && rm -rf build/ \
  && mkdir -p build && cd build/ \
  && ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers \
  && make \
  && checkinstall --install=no --pkgversion 1 --pakdir /opt/deb --nodoc -y\
  && git clean -f

cd /tmp/xcb-util-xrm &&\
  checkinstall --install=no --pkgversion 1 --pakdir /opt/deb --nodoc -y\

