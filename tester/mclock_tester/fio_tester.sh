#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg
fio_rw_dmclock=${BASEDIR}/fio_rw_dmclock.sh
process_raw_data=${BASEDIR}/process_raw_data_by_dmclock.sh
send_result=${BASEDIR}/backup_send_result.sh

$fio_rw_dmclock
$process_raw_data
$send_result

exit 0
