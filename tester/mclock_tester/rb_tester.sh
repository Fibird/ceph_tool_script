#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg

rados_bench_dmclock={BASHDIR}/rb_rw_dmclock.sh
process_raw_data=${BASEDIR}/process_raw_data_by_rwwindow.sh
send_result=${BASEDIR}/backup_send_result.sh

$rados_bench_dmclock
$process_raw_data
$send_result

exit 0
