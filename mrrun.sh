#!/usr/bin/env bash
# ex: set filetype=sh :
##
##Usage:  __SCRIPT__ REMOTEHOST [REMOTEPORT]
##configures whatever action with whatever config
##    REMOTEHOST: remote host where to ssh
##    REMOTEPORT: JMX port (default: 12345)
##
## Author: Jeff Malone, 09 Feb 2018
##

set -euxo pipefail

# function usage() { sed -r -n -e s/__SCRIPT__/$(basename $0)/ -e '/^##/s/^..// p'   $0 ; }

# [[ $# -eq 1 && ( $1 == -h || $1 == --help ) ]] && usage && exit 0

# [[ $# -lt 1 || $# -gt 2 ]] && echo FATAL: incorrect number of args && usage && exit 1

# for i in sed which grep; do ! command -v $i &>/dev/null && echo FATAL: unexisting dependency $i && exit 1; done

BUILD_DIR=~/i3
rmdir $BUILD_DIR &>/dev/null || true # silently try to removes empty directory
if ! mkdir $BUILD_DIR; then
    echo "FATAL can't mkdir $BUILD_DIR, please remove it yourself before continuing"
    exit 1
fi
DIR="$( cd -P "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
NAME=$(basename $DIR)

cd $DIR
ref=gaps
echo "
FROM ubuntu:$(lsb_release -r | awk '{print $2}')
RUN true \
    && apt-get update \
    && apt-get install -y \
        apt-utils \
        checkinstall \
        dh-autoreconf \
        git \
        libpango1.0-dev \
        libxcb-keysyms1-dev \
        libxcb-shape0-dev \
        libxcb-util0-dev \
        libxcb1-dev \
        libev-dev \
        libstartup-notification0-dev \
        libxcb-cursor-dev \
        libxcb-icccm4-dev \
        libxcb-randr0-dev \
        libxcb-xinerama0-dev \
        libxcb-xkb-dev \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        libyajl-dev \
        xutils-dev \
    && true

RUN git clone --recursive https://github.com/Airblader/xcb-util-xrm.git /tmp/xcb-util-xrm
WORKDIR /tmp/xcb-util-xrm
RUN ./autogen.sh
RUN make
RUN make install

ADD generate.sh /opt/

RUN mkdir /opt/i3-gaps
WORKDIR /opt
CMD [ \"sh\", \"generate.sh\", \"$ref\" ]
" | \
docker build --network=host -f - -t $NAME .
# --net=HOST
docker run --network=host --rm -v $BUILD_DIR/i3:/opt/i3-gaps -v $BUILD_DIR/deb:/opt/deb $NAME
sudo apt remove i3-wm
sudo dpkg -i $BUILD_DIR/deb/*.deb
sudo ldconfig
sudo rm -rf $BUILD_DIR
echo "please reboot"

exit 0
