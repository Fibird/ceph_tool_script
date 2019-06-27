#!/bin/bash


BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

# kill all ceph daemon
$BASEDIR/kill-ceph.sh
$BASEDIR/kill-ceph.sh
$BASEDIR/kill-ceph.sh
# clear osd data
for od in $(ls -d /var/lib/ceph/osd/ceph-*); do 
    umount $od; 
done

exit 0
