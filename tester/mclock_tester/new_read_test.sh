ceph osd pool set test0 qos_res 1
ceph osd pool set test0 qos_wgt 1
ceph osd pool set test0 qos_lim 800

for i in {1..4}; do
    ceph osd pool set test$i qos_res 1
    ceph osd pool set test$i qos_wgt 1
    ceph osd pool set test$i qos_lim 0
done

rados bench -p test0 200 rand -t 96 > 1read_tmp_test_log0_1 &
rados bench -p test0 200 rand -t 96 > 1read_tmp_test_log0_2 &
rados bench -p test0 200 rand -t 96 > 1read_tmp_test_log0_3 &

for i in {1..2}; do
    rados bench -p test$i 200 rand -t 32 > 1read_tmp_test_log$i &
done

