#!/bin/bash
# procedures of test ceph
# Written by Liu Chaoyang

BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

# generate config files
./gen_ceph_confs.sh
if [[ 0 -ne $? ]]; then
    echo "[ERROR]: Generate config files failed!"
    exit -1
fi

# copy config file to /etc/ceph/ceph.conf
for q in ${queue_list[@]}; do

    # reinstall ceph rpms on local host
    ${BASEDIR}/remove_rpm.sh
    rpm -ivh --nodeps "$q"_rpms/*.rpm
    # check if install successfully 
    if [[ 0 -ne $? ]]; then
        echo "[ERROR]: Install ceph failed!"
        exit -1
    else
        echo "[INFO]: Install ceph succeeded."
    fi
    
    # reinstall ceph on remote hosts
    for h in ${remote_host_list[@]}; do
        ssh $h "$remote_script_dir/remove_rpm.sh"
    	ssh $h "rpm -ivh --nodeps $remote_script_dir/'$q'_rpms/*.rpm"
        # check if install successfully 
        if [[ 0 -ne $? ]]; then
            echo "[ERROR]: Install ceph failed!"
            exit -1
        else
            echo "[INFO]: Install ceph succeeded."
        fi
    done

    conf_dir="$q"_conf
    for c in $(seq 0 $((case_num-1))); do
        for t in $(seq 0 $((test_num-1))); do
            
    	    # purge ceph env and config ceph locally
	    ${BASEDIR}/purge-all.sh
	    # clear osd data
            ${BASEDIR}/clear_osd_data.sh
            ${BASEDIR}/clear_osd_data.sh

            ### deploy ###
            # deploy on local
	    mkdir /etc/ceph
            cp $conf_dir/ceph.conf.$c /etc/ceph/ceph.conf
            if [[ 0 -ne $? ]]; then
                echo "[ERROR]: Config file move failed!"
                exit -1
            fi

	    ${BASEDIR}/gen-keyring.sh
	    ${BASEDIR}/init-mon.sh
	    ${BASEDIR}/start-mon.sh

            ${BASEDIR}/add_osd.sh ${disk_list[@]}
            if [[ 0 -ne $? ]]; then
                echo "[ERROR]: Add osd failed!"
                exit -1
            fi
            # deploy on remote
            ${BASEDIR}/deploy_remote.sh 
        
            # create pools
            ${BASEDIR}/create_pools.sh 
            if [[ 0 -ne $? ]]; then
                echo "[ERROR]: Create pools failed!"
                exit -1
            fi
            ### test ###
            # call rados bench script
            ${BASEDIR}/rados_bench_in_batch.sh ${shard_list[$c]}s${thread_list[$c]}t $t $q
            if [[ 0 -ne $? ]]; then
                echo "[ERROR]: rados bench test $q failed!"
		echo "What a pity! Test failed when test $q." | mail -s "Test Failed" chaoyanglius@outlook.com
                exit -1
            else
                echo "[INFO]: rados bench test for $q succeeded."
		echo "Yes! Test for $q succeeded." | mail -s "Test Succeeded" chaoyanglius@outlook.com
            fi

            # remove pools
            ${BASEDIR}/remove_pools.sh
            if [[ 0 -ne $? ]]; then
                echo "[ERROR]: Remove pools failed!"
                exit -1
            fi
        done
    done
done

echo "[INFO]: Congratulations! Test finished."

echo "[INFO]: Taring result and send it..."
# tar result and send result
date_time=$(date +%y%m%d)
result_file=sttest_result_"$date_time".tar.gz
tar -czvf $result_file $result_dir/*
scp $result_file lcy@202.112.113.24:/home/lcy/
echo "Congratulations! Test Complete!" | mail -s "Test Complete" chaoyanglius@outlook.com

exit 0
