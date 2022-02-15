#!/usr/bin/env bash
# ex: set filetype=sh :

set -euxo pipefail
umask 027
export PATH=/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:~/bin

OS=ubuntu:$(lsb_release -r | awk '{print $2}')
DIR="$( cd -P "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
NAME=shk3bq4d/$(basename $DIR)-$OS

docker login
docker push $NAME

exit 0
