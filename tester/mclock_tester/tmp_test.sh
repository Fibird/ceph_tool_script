
rados bench -p test0 300 write -b 16K -t 128 > tmp_test0 &
rados bench -p test0 300 write -b 16K -t 128 > tmp_test0_1 &
rados bench -p test1 300 write -b 16K -t 128 > tmp_test1 &
rados bench -p test1 300 write -b 16K -t 128 > tmp_test1_1 &
rados bench -p test2 300 write -b 16K -t 128 > tmp_test2 &
rados bench -p test2 300 write -b 16K -t 128 > tmp_test2_1 &
rados bench -p test3 300 write -b 16K -t 64 > tmp_test3 &
rados bench -p test3 300 write -b 16K -t 64 > tmp_test3_1 &
rados bench -p test4 300 write -b 16K -t 64 > tmp_test4 &
rados bench -p test4 300 write -b 16K -t 64 > tmp_test4_1 &
