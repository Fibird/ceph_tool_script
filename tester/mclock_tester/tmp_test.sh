
#rados bench -p test0 300 write -b 16K -t 128 > tmp_test0 &
#rados bench -p test1 300 write -b 16K -t 128 > tmp_test1 &
#rados bench -p test2 300 write -b 16K -t 128 > tmp_test2 &
#rados bench -p test3 300 write -b 16K -t 128 > tmp_test3 &
#rados bench -p test4 300 write -b 16K -t 128 > tmp_test4 &

ceph osd pool set test0 qos_res 1
ceph osd pool set test0 qos_wgt 1
ceph osd pool set test0 qos_lim 800

for i in {1..4}; do
    ceph osd pool set test$i qos_res 1
    ceph osd pool set test$i qos_wgt 1
    ceph osd pool set test$i qos_lim 0
done

rados bench -p test0 200 write -b 16K -t 32 > tmp_test_log0_0 --run-name test0_0 &
rados bench -p test0 200 write -b 16K -t 32 > tmp_test_log0_1 --run-name test0_1 &
rados bench -p test0 200 write -b 16K -t 32 > tmp_test_log0_2 --run-name test0_2 &
rados bench -p test0 200 write -b 16K -t 32 > tmp_test_log0_3 --run-name test0_3 &

for i in {1..4}; do
#for i in {0..4}; do
    rados bench -p test$i 200 write -b 16K -t 128 > tmp_test_log$i --run-name test$i &
    #rados bench -p test$i 200 write -b 16K -t 32 > tmp_test_log$i --run-name test$i &
done

