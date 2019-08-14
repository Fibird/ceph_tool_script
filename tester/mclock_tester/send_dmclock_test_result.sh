#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg

send_file_name=${BASEDIR}/mclock_test_result_$(date +%y%m%d%H%M%S)

tar -czvf "$send_file_name".tar.gz ${BASEDIR}/$result_dir/*
echo $info_mail
echo -e "Sir,\n\n Test complete and please check!\n\nTBot" | mail -s "mclock test" -a "$send_file_name".tar.gz $info_email

exit 0
