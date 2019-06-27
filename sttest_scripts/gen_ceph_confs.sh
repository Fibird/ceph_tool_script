#!/bin/bash
# Generate plenty of config files
# eg: wpq_conf/ceph.conf.0, wpq_conf/ceph.conf.1, 
#     mclock_pool_conf/ceph.conf.0
# Written by Liu Chaoyang
# Test by Liu Chaoyang

# config list
#shard_list=(1 10 1 16 1)
#thread_list=(1 1 10 1 16)
#queue_list=(wpq mclock_pool)
BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg
. ${BASEDIR}/config.sh

if [[ ${#shard_list[@]} -ne ${#thread_list[@]} ]]; then
    echo "[ERROR: ] size of shard list is not consistent with thread list!"
    exit -1
fi

#fsid=$(uuidgen)
mon_name=$(hostname)
mon_ip=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
public_network=10.10.120.0/24

for q in ${queue_list[@]}; do
    mkdir "$q"_conf
    end=$((case_num-1))
    for i in $(seq 0 $end); do
        config_file="$q"_conf/ceph.conf.$i
        cat /dev/null > $config_file 
        echo "[global]" >> $config_file
        echo "fsid=$fsid" >> $config_file
        echo "mon initial members = $mon_name" >> $config_file
	echo "mon host = $mon_ip" >> $config_file
        echo "public network=$public_network" >> $config_file
        echo "auth cluster required = cephx" >> $config_file
        echo "auth service required = cephx" >> $config_file
        echo "auth client required = cephx" >> $config_file
        echo "osd journal size = 1024" >> $config_file
        echo "filestore xattr use omap = true" >> $config_file
        echo "osd_op_queue=$q" >> $config_file
        echo "mon_allow_pool_delete=true" >> $config_file
        echo "osd_op_num_shards_hdd=1" >> $config_file
        echo "osd_op_num_shards_ssd=1" >> $config_file
        echo "osd_op_num_threads_per_shard_ssd=1" >> $config_file
	echo "osd_op_num_threads_per_shard_hdd=1" >> $config_file
        echo "objecter_mclock_service_tracker = true" >> $config_file
	echo "objecter_inflight_ops=0" >> $config_file
	echo "objecter_inflight_op_bytes=0" >> $config_file
        echo "osd_op_num_shards = ${shard_list[i]}" >> $config_file
        echo "osd_op_num_threads_per_shard = ${thread_list[i]}" >> $config_file
        echo "osd_pool_default_size=2" >> $config_file
        echo "osd_pool_default_min_size=1" >> $config_file
	echo "osd_op_queue_cut_off=high" >> $config_file
    done
done

echo "[INFO]: Generate all config files succeeded."

exit 0
