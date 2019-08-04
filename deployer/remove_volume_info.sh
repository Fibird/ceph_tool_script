#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "Please input device path(s)!"	
	exit -1
fi

dev_list=("$@")

dmsetup remove_all
for dl in ${dev_list[@]}; do
    volume_group=$(pvdisplay $dl | grep "VG Name" | awk '{print $3}')
    vgremove $volume_group --yes
    pvremove $dl --yes
    ceph-volume lvm zap $dl
done

exit 0
