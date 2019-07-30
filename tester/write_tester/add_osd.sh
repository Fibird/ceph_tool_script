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

# get host name
# set cluster name by host name
cluster_name=ceph

for osd_disk_path in ${osd_disk_path_list[@]}; do
    # get osd id
    osd_secret=$(ceph-authtool --gen-print-key)
    osd_uuid=$(uuidgen)
    osd_id=$(echo "{\"cephx_secret\": \"$osd_secret\"}" | \
    ceph osd new $osd_uuid -i - \
    -n client.bootstrap-osd -k /var/lib/ceph/bootstrap-osd/ceph.keyring)

    if [[ -z "$osd_id" ]]; then
        echo "[ERROR:] Could not get osd id!"
	exit -1
    fi

    echo "[INFO: ] Creating osd.$osd_id..."
    # create osd data directory
    osd_data=/var/lib/ceph/osd/ceph-$osd_id
    mkdir -p $osd_data
    # format to xfs
    mkfs.xfs $osd_disk_path -f
    # mount 
    mount $osd_disk_path $osd_data
    # generate keyring
    ceph-authtool --create-keyring $osd_data/keyring --name osd.$osd_id --add-key $osd_secret
    # start osd
    ceph-osd -i $osd_id --mkfs --osd-uuid $osd_uuid --osd-data $osd_data 
    ceph-osd -i $osd_id --cluster $cluster_name --osd-data /var/lib/ceph/osd/ceph-$osd_id
    #ceph-osd -i $osd_id --cluster $cluster_name --osd-data /var/lib/ceph/osd/ceph-$osd_id
    echo "[INFO: ] osd.$osd_id created on $osd_disk_path successfully."
done

exit 0
