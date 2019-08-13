#!/bin/bash

BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

if [[ -n $1 ]]; then
    pool_name=$1
else
    echo "Please input pool name!"
fi

if [[ -n $2 ]]; then
    rbd_name=$2
else
    echo "Please input rbd name!"
fi

if [[ -n $3 ]]; then
    rbd_size=$3
else
    echo "Please input rbd size!"
fi

rbd create --size $rbd_size $pool_name/$rbd_name 
rbd feature disable $pool_name/$rbd_name exclusive-lock, object-map, fast-diff, deep-flatten --pool $pool_name
rbd map $pool_name/$rbd_name --pool $pool_name
mkfs.ext4 /dev/$rbd_name

exit 0
