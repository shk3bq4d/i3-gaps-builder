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
echo docker pull $NAME;
if ! docker pull $NAME; then
    echo "Can't pull, let's start building"
    ./mrbuild-runner.sh
fi

# --net=HOST
docker run --network=host --rm -v $BUILD_DIR/i3:/opt/i3-gaps -v $BUILD_DIR/mytarget:/mytarget $NAME $ref
sudo apt remove i3-wm i3-gaps\* i3blocks || true

realhosttarget=/usr/local
savefile=$realhosttarget/i3-gaps-builder-files.$(date +'%Y.%m.%d-%H.%M.%S').txt
umask 022

cd $BUILD_DIR/mytarget
{
    echo "========== A"
    find -type f | sed -r -e "s,^(\\./)?,$realhosttarget/,"
    echo "========== B"
    find -type f -ls
    echo "========== C"
    find -type f -print0 | xargs -r0 sha256sum
    echo "========== D"
} | sudo tee $savefile
sudo rsync -avr $BUILD_DIR/mytarget/. $realhosttarget/.
sudo ldconfig
echo "
----- BEFORE
$BEFORE

----- AFTER
$(i3 -version)

-----
please reboot
"
sudo chown -R $USER $BUILD_DIR
cleanup

exit 0
