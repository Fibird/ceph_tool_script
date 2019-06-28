#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

## 1 shard 1 thread 300 threads 4K 
#BLOCK_SIZE=(4K)
#BLOCK_SIZE=(1M)
#THREAD_NUM=(300 350 400)
#THREAD_NUM=(350 500 1200 1500)
#THREAD_NUM=(400)
#test_time=180

# get from command argument
shardAndThread=1s1t

if [[ -n $1 ]]; then
    shardAndThread=$1
fi

test_id=0
if [[ -n $2 ]]; then
    test_id=$2
fi

q_result=wpq
if [[ -n $3 ]]; then
    q_result=$3
fi

declare -a pids
echo "block size list: ${block_size_list[@]}"
for bs in ${block_size_list[@]}; do
    echo -e "rados thread list $bs: "
    eval echo '${'"rados_thread_list_$bs[@]"'}'
    for tn in $(eval echo '${'"rados_thread_list_$bs[@]"'}'); do
        echo "Start to test $shardAndThread $bs $tn"
	    tnum=`expr $tn / 5`
	    for ((i=0;i<=4;i++)); do 
    	        POOL_NAME=test$i
                rados bench -p $POOL_NAME $test_time write -b $bs -t $tnum > ${BASEDIR}/$result_dir/$q_result/$shardAndThread$bs-$tn-$POOL_NAME-$test_id &
	        echo "Run: rados bench -p $POOL_NAME $test_time write -b $bs -t $tnum > ${BASEDIR}/$result_dir/$q_result/$shardAndThread$bs-$tn-$POOL_NAME-$test_id"
	        echo "Pid: $!"
    	        pids[i]=$!    
	    done
	    echo "Waiting for test..."
	    for i in ${pids[@]}; do 
	        wait $i
	    done
    done
done

exit 0

