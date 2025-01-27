#!/usr/bin/env bash
# ex: set filetype=sh :

set -euxo pipefail
umask 027
export PATH=/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:~/bin

BEFORE="$(i3 -version || echo "i3 not installed")"

BUILD_DIR=$(mktemp -d);
function cleanup() { [[ -n "${_tempdir:-}" && -d "$_tempdir" ]] && rm -rf $_tempdir || true; };
#trap 'cleanup' SIGHUP SIGINT SIGQUIT SIGTERM EXIT
rmdir $BUILD_DIR &>/dev/null || true # silently try to removes empty directory
if ! mkdir $BUILD_DIR; then
    echo "FATAL can't mkdir $BUILD_DIR, please remove it yourself before continuing"
    exit 1
fi
DIR="$( cd -P "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
OS=ubuntu:$(lsb_release -r | awk '{print $2}')
NAME=shk3bq4d/$(basename $DIR)-$OS

cd $DIR
ref=gaps # gaps no longer builds the same, see https://github.com/i3/i3/issues/4086 and 358471a5f207886ef370d14d161a48618cf4f1f5
ref=gaps-next
ref=gaps # well I am switching to meson

echo rebuilding/refreshing
echo "
FROM $OS"'
ENV DEBIAN_FRONTEND=noninteractive
RUN true \
    &&  apt-get update \
    &&  apt-get install -y \
        apt \
        apt-utils \
        checkinstall \
        dh-autoreconf \
        doxygen \
        git \
        libev-dev \
        libpango1.0-dev \
        libstartup-notification0-dev \
        libxcb1-dev \
        libxcb-cursor-dev \
        libxcb-icccm4-dev \
        libxcb-keysyms1-dev \
        libxcb-randr0-dev \
        libxcb-shape0 \
        libxcb-shape0-dev \
        libxcb-util0-dev \
        libxcb-xinerama0-dev \
        libxcb-xkb-dev \
        libxcb-xrm0 \
        libxcb-xrm-dev \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        libyajl-dev \
        meson \
        xcb \
        xutils-dev \
    && true

#RUN git clone --recursive https://github.com/Airblader/xcb-util-xrm.git /tmp/xcb-util-xrm
RUN git clone --recursive https://github.com/shk3bq4d/xcb-util-xrm.git /tmp/xcb-util-xrm
WORKDIR /tmp/xcb-util-xrm
RUN ./autogen.sh
RUN make
RUN make install

ADD add/generate.sh /opt/

RUN mkdir /opt/i3-gaps
WORKDIR /opt
ENTRYPOINT [ "sh", "generate.sh"]
' | docker build --network=host -f - -t $NAME .
echo "success, I suggest you push"

exit 0
