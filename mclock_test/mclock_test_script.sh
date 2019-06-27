#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg
create_pools=$BASEDIR/create_pools.sh
remove_pools=$BASEDIR/remove_pools.sh

declare -a pids
echo "block size list: ${block_size_list[@]}"
for bs in ${block_size_list[@]}; do
    # read qos setting one by one
    cat $BASEDIR/qos_configs.csv | while read rwl;
    do
	# rwl can not be null
	if [[ -n "$rwl" ]]; then
	    # create new pools
	    $create_pools
	    # get qos config from csv
	    qos_id=($(echo $rwl | awk -F ',' '{print $1}'))
	    r_list=($(echo $rwl | awk -F ',' '{print $2}'))
	    w_list=($(echo $rwl | awk -F ',' '{print $3}'))
	    l_list=($(echo $rwl | awk -F ',' '{print $4}'))
	    # set qos for pools
	    for ((i=0;i<=$pool_num;i++)); do
		ceph osd pool set test$i qos_wgt ${r_list[$i]}
		ceph osd pool set test$i qos_res ${w_list[$i]}
		ceph osd pool set test$i qos_lim ${l_list[$i]}
	    done
	    echo "show all pools settings."
	    for((i=0;i<5;i++)); do
		echo "pool test$i"
		ceph osd pool get test$i qos_res
		ceph osd pool get test$i qos_wgt
		ceph osd pool get test$i qos_lim
	    done

	    for ((i=0;i<=4;i++)); do 
    	        pool_name=$pool_name_prefix$i
		result_file_name=$bs-$pool_name-$qos_id
                rados bench -p $pool_name $time_per_test write -b $bs -t $rados_thread_num > ${BASEDIR}/$result_dir/$result_file_name &
		echo "[INFO]: PID:$!: rados bench writing to $pool_name ..."
    	        pids[i]=$!    
	    done
	    echo "[INFO]: Waiting for test..."
	    for i in ${pids[@]}; do 
	        wait $i
	    done
	    # process result
	    # get IOPS
	    # write to result_date.csv
	    # format:
	    # qos_id,r:value w:value l:value, iops
	    # clean all pools
	    $remove_pools
	fi
    done
done

exit 0

