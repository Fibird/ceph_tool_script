#!/bin/bash

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg

for i in $(seq 0 $((pool_num-1))); do
    pool_name=$pool_name_prefix$i
    rbd_name=$rbd_name_prefix$i
    rbd create --size $rbd_size $pool_name/$rbd_name 
    rbd feature disable $pool_name/$rbd_name exclusive-lock, object-map, fast-diff, deep-flatten --pool $pool_name
    rbd map $pool_name/$rbd_name --pool $pool_name
    mkfs.ext4 /dev/$rbd_name
done

exit 0
