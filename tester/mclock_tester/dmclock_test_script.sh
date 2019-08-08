#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg
create_pools=${BASEDIR}/create_pools.sh
remove_pools=${BASEDIR}/remove_pools.sh
create_rbds=${BASEDIR}/create_rbds.sh
remove_rbds=${BASEDIR}/remove_rbds.sh

declare -a pids
echo "block size list: ${block_size_list[@]}"
for bs in ${block_size_list[@]}; do
    line_num=0
    suffix=$(date +%y%m%d%H%M%S)
    iops_rst_file=${BASEDIR}/$result_dir/"$bs"_result_iops_"$suffix".csv
    echo "id,pool,r,w,l,iops" >> $iops_rst_file
    # read qos setting one by one
    cat $BASEDIR/"$bs"_"$qos_file_name" | while read rwl; do
        # jump header line
        # rwl can not be null
        if [[ "$line_num" -ne 0 ]] && [[ -n "$rwl" ]]; then
            # create new pools
            $create_pools
            # get qos config from csv
            qos_id=($(echo $rwl | awk -F ',' '{print $1}'))
            r_list=($(echo $rwl | awk -F ',' '{print $2}'))
            w_list=($(echo $rwl | awk -F ',' '{print $3}'))
            l_list=($(echo $rwl | awk -F ',' '{print $4}'))
            # set qos for pools
            for ((i=0;i<$pool_num;i++)); do
                ceph osd pool set test$i qos_res ${r_list[$i]}
                ceph osd pool set test$i qos_wgt ${w_list[$i]}
                ceph osd pool set test$i qos_lim ${l_list[$i]}
            done
            echo "show all pools settings."
            for((i=0;i<$pool_num;i++)); do
                echo "pool test$i"
                ceph osd pool get test$i qos_res
                ceph osd pool get test$i qos_wgt
                ceph osd pool get test$i qos_lim
            done

            for ((i=0;i<$pool_num;i++)); do 
                pool_name=$pool_name_prefix$i
                rbd_name=$rbd_name_prefix$i
                result_file_name=${BASEDIR}/$result_dir/$bs-$pool_name-$qos_id
#                rados bench -p $pool_name $time_per_test write -b $bs -t $rados_thread_num > $result_file_name &
#                echo "[INFO]: PID:$!: rados bench writing to "$pool_name"..."
                fio -ioengine=rbd -clientname=admin -pool=$pool_name -rbdname=$rbd_name -iodepth=32 -runtime=$time_per_test -rw=write -bs=$bs -name="$bs"_write_"$i" > $result_file_name &
                pids[i]=$! 
            done
            echo "[INFO]: Waiting for test..."
            for i in ${pids[@]}; do 
                wait $i
            done
            
            # process results
            for ((i=0;i<$pool_num;i++)); do
                pool_name=$pool_name_prefix$i
                result_file_name=${BASEDIR}/$result_dir/$bs-$pool_name-$qos_id
                #iops=$(grep "Average IOPS" $result_file_name | awk '{print $3}')
                iops=$(grep "write: IOPS=" $result_file_name | awk '{print $2}' | tr -d  'IOPS=,')
                r_value=${r_list[$i]}
                w_value=${w_list[$i]}
                l_value=${l_list[$i]}
                echo "$qos_id,$pool_name,$r_value,$w_value,$l_value,$iops" >> $iops_rst_file
            done
            # clean all pools
            $remove_pools
            #echo -e "Sir,\n\n \t I have finished testing for $bs config $line_num.\n\nTBot\n" | mail -s "mclock test" $info_email
        fi
        ((line_num++))
    done
done

send_file_name=${BASEDIR}/mclock_test_result_$(date +%y%m%d%H%M%S)

tar -czvf "$send_file_name".tar.gz ${BASEDIR}/$result_dir/*
echo $info_mail
echo -e "Sir,\n\n Test complete and please check!\n\nTBot" | mail -s "mclock test" -a "$send_file_name".tar.gz $info_email

exit 0

