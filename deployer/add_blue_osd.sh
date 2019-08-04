#!/bin/bash
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to add osd in batch into osd.
# **Note:** This script must be run by root
# 2019-05-14 16:09

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "This script must be run by root!"
    exit 1
fi

osd_disk_path_list=("$@")

osd_count=${#osd_disk_path_list[@]}
#echo ${osd_disk_path_list[@]}
echo "[INFO: ] $osd_count osds will be created."
# start to create osds

if [[ ! -d /var/lib/ceph/osd/ ]]; then
    mkdir -p /var/lib/ceph/osd/
fi

for osd_disk_path in ${osd_disk_path_list[@]}; do
    ceph-volume lvm create --data $osd_disk_path --bluestore
    echo "[INFO: ] osd.$osd_id created on $osd_disk_path successfully."
done

exit 0
