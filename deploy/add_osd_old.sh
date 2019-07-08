#!/bin/bash
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to add osd in batch into ceph cluster. 
# **Note:** This script must be run by root
# 2019-05-14 16:09

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "This script must be run by root!"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Please input some disk paths."
    exit 1 
fi

osd_disk_path_list=("$@")

# are you sure?
echo ${osd_disk_path_list[@]}
echo "These path will be created osd and they will be formated."
echo -n "Are you sure to use them? (y/n)"
read if_sure

if [[ $if_sure == "n" ]]; then
    echo "GoodBye!"
    exit 0
elif [[ $if_sure == "y" ]]; then
    echo "[INFO:] Starting to create osd..." 
else
    echo "Please enter 'y' or 'n'!"
    exit 1
fi 

# start to create osds

# get host name
host_name=$(hostname)
# set cluster name by host name
cluster_name=ceph

# add host to crush map
#ceph osd crush add-bucket $host_name host
#ceph osd crush move $host_name root=default

#osd_disk_path_list=/dev/sda1

# osd counter
osd_count=0

for osd_disk_path in ${osd_disk_path_list[@]}; do
    # get osd id
    osd_id=$(ceph osd create)
    osd_list[osd_count]=$osd_id
    echo "[INFO: ] Creating osd.$osd_id..."
    # create osd data directory
    osd_data=/var/lib/ceph/osd/ceph-$osd_id
    mkdir -p $osd_data
    # format to xfs
    mkfs.xfs $osd_disk_path -f
    # mount 
    mount $osd_disk_path $osd_data
    # initialize the OSD data directory
    ceph-osd -i $osd_id --mkfs --mkkey
    # register the OSD authentication key
    ceph auth add osd.$osd_id osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-$osd_id/keyring
    # add osd into crush map
    #ceph osd crush add osd.$osd_id 1.00 root=default host=$host_name
    # start osd
    ceph-osd -i $osd_id --cluster $cluster_name --osd-data /var/lib/ceph/osd/ceph-$osd_id
    ceph-osd -i $osd_id --cluster $cluster_name --osd-data /var/lib/ceph/osd/ceph-$osd_id
    echo "[INFO: ] osd.$osd_id created successfully."
    ((osd_count++))
done

echo "Created $osd_num osds:"
echo "OSD   DISK   DATA" >> /etc/ceph/ceph_osd.info
for ((i=0; i < osd_num; i++)) do
    echo -e "osd.${osd_list[$i]}   ${osd_disk_path_list[$i]}   /var/lib/ceph/osd/ceph-${osd_list[$i]}" >> /etc/ceph/ceph_osd.info
done

cat /etc/ceph/ceph_osd.info

exit 0
