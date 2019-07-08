#!/bin/bash -x


BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh


monmaptool --create --add $host_name $mon_ip_list --fsid $fsid $TMP_MON_MAP

mkdir -p /var/lib/ceph/mon/$cluster_name-$host_name

ceph-mon --mkfs -i $host_name --monmap $TMP_MON_MAP --keyring $TMP_MON_KEYRING






