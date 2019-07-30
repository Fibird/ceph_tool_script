#!/bin/bash 

# get from command argument
shardAndThread=$1
test_id=$2
shardAndThread=1
test_id=2
test_time=5
block_size_list=(4K 4M)
rados_thread_list_4K=(300 200 100)
rados_thread_list_4M=(300 200 100)
for bs in ${block_size_list[@]}; do
    for tn in $(eval echo '${'"rados_thread_list_$bs[@]"'}'); do
        echo "Start to test $shardAndThread $bs $tn"
	    tnum=`expr $tn / 5`
	    for ((i=0;i<=4;i++)); do 
    	    POOL_NAME=test$i
            rados bench -p $POOL_NAME $test_time write -b $bs -t $tnum            > ${BASEDIR}/$result_dir/$shardAndThread$bs-$tn-$POOL_NAME-$test_id &
	        echo "Run: rados bench -p $POOL_NAME $test_time write -b $bs -t $tnum > ${BASEDIR}/$result_dir/$shardAndThread$bs-$tn-$POOL_NAME-$test_id"
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

