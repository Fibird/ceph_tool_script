#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg

echo "block size list: ${block_size_list[@]}"
for bs in ${block_size_list[@]}; do
    line_num=0
    suffix=$(date +%y%m%d%H%M%S)
    iops_rst_file=${BASEDIR}/$result_dir/"$bs"_result_iops_"$suffix".csv
    echo "id,pool,r,w,l,iops,ept_iops" >> $iops_rst_file
    # read qos setting one by one
    cat $BASEDIR/"$bs"_"$qos_file_name" | while read rwl; do
        # jump header line
        # rwl can not be null
        if [[ "$line_num" -ne 0 ]] && [[ -n "$rwl" ]]; then
            # get qos config from csv
            qos_id=($(echo $rwl | awk -F ',' '{print $1}'))
            r_list=($(echo $rwl | awk -F ',' '{print $2}'))
            w_list=($(echo $rwl | awk -F ',' '{print $3}'))
            l_list=($(echo $rwl | awk -F ',' '{print $4}'))

            iops_sum=0;  res_sum=0;  wgt_sum=0;  lim_sum=0;  rem_sum=0
            declare -a iopses
            declare -a ept_iopses

            # process results
            for ((i=0;i<$pool_num;i++)); do
                pool_name=$pool_name_prefix$i
                result_file_name=${BASEDIR}/$result_dir/$bs-$pool_name-$qos_id
                iops=$(grep "write: IOPS=" $result_file_name | awk '{print $2}' | tr -d  'IOPS=,')
                iopses[$i]=$iops
                r_value=${r_list[$i]}
                w_value=${w_list[$i]}
                l_value=${l_list[$i]}
                ((iops_sum+=iops))
                ((res_sum+=r_value))
                ((wgt_sum+=w_value))
                ((lim_sum+=l_value))
                rem_sum=$((iops_sum-res_sum))
                ept_iopses[$i]=$r_value
            done

            # first allocation
            bonus_iops=0; rem_wgt=0
            for ((i=0;i<$pool_num;i++)); do
                if [[ $rem_sum -gt 0 ]]; then
                    ept_iopses[$i]=$((r_list[$i]+rem_sum*w_list[$i]/wgt_sum))
                    if [[ ${l_list[$i]} -ne 0 && ${ept_iopses[$i]} -gt ${l_list[$i]} ]]; then
                        ept_iopses[$i]=${l_list[$i]}
                        bonus_iops=$((bonus_iops+ept_iopses[$i]-l_list[$i]))
                    else
                        ((rem_wgt+=w_list[$i]))
                    fi
                fi
            done

            # allocate remain iops after first allocation
            if [[ $bonus_iops -ne 0 ]]; then
                for ((i=0;i<$pool_num;i++)); do
                    if [[ ${l_list[$i]} -eq 0 || ${ept_iopses[$i]} -lt ${l_list[$i]} ]]; then
                        ept_iopses[$i]=$((ept_iopses[$i]+bonus_iops*w_list[$i]/rem_wgt[$i]))    
                    fi
                done
            fi

            # print iops
            for ((i=0;i<$pool_num;i++)); do
                pool_name=$pool_name_prefix$i
                result_file_name=${BASEDIR}/$result_dir/$bs-$pool_name-$qos_id
                r_value=${r_list[$i]}
                w_value=${w_list[$i]}
                l_value=${l_list[$i]}
                iops=${iopses[$i]}
                ept_iops=${ept_iopses[$i]}
                echo "$qos_id,$pool_name,$r_value,$w_value,$l_value,$iops,$ept_iops" >> $iops_rst_file
            done
        fi
        ((line_num++))
    done
done

#send_file_name=${BASEDIR}/mclock_test_result_$(date +%y%m%d%H%M%S)

#tar -czvf "$send_file_name".tar.gz ${BASEDIR}/$result_dir/*
#echo $info_mail
#echo -e "Sir,\n\n Test complete and please check!\n\nTBot" | mail -s "mclock test" -a "$send_file_name".tar.gz $info_email

exit 0
