#!/bin/bash

# load scripts configurations
BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

# remote commands
kill_ceph="$remote_script_dir/kill-ceph.sh"
# restart_mon="$remote_script_dir/restart-mon.sh"
restart_osd="$remote_script_dir/restart-osd.sh"
add_osd="$remote_script_dir/add_osd.sh"
clear_osd_data="$remote_script_dir/clear_osd_data.sh"

# deploy on remote host
echo "[INFO]: Deploy on ${remote_host_list[@]}."
# copy config files
for h in ${remote_host_list[@]}; do
    scp -r /etc/ceph/ $h:/etc/
    if [[ 0 -eq $? ]]; then
        echo "[INFO]: Configuration files and keyring copy succeeded."
    else 
        echo "[ERROR]: Configuration files and keyring copy failed!"
    fi 

    scp -r /var/lib/ceph/bootstrap-osd/ $h:/var/lib/ceph/
    if [[ 0 -eq $? ]]; then
        echo "[INFO]: Configuration and keyring files copy succeeded."
    else 
        echo "[ERROR]: Configuration files and keyring copy failed!"
    fi 

    scp -r /var/lib/ceph/mon/ $h:/var/lib/ceph/
    if [[ 0 -eq $? ]]; then
        echo "[INFO]: Configuration and keyring files copy succeeded."
    else 
        echo "[ERROR]: Configuration files and keyring copy failed!"
    fi 
done

# restart hosts
for h in ${remote_host_list[@]}; do
    # ssh $h "echo test > test.lcy.txt"
    ssh $h "$kill_ceph"
    ssh $h "$kill_ceph"
    ssh $h "$kill_ceph"
    ssh $h "$clear_osd_data"
    ssh $h "$clear_osd_data"
    #ssh $h "$restart_osd"
    ssh $h "$add_osd ${disk_list[@]}"
done

exit 0
