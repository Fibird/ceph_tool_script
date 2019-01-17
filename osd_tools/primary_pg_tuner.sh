#!/bin/bash

# --------------------------------------------------------
# Shell script to tune primary pg number by osd
# Copyright(c)2019 Liu Chaoyang (chaoyanglius@gmail.com) 
# --------------------------------------------------------

# Parameters
# 1.pool name or id
# 2.maximum iteration times
# 3.maximum deviation

# Get primary pg number

if [[ $# -ne 2 ]]
then
  echo "Please specify pool id and iteration times!"
  exit 1
fi

pool_id=$1
set_dev=2
iter_times=$2

# get osd list
osd_list=($(ceph osd ls))

# get pool list
pool_id_list=($(ceph osd lspools | awk '{print $1}'))

# get osd primary affinity
osd_pri_aff=($(ceph osd tree | awk '/osd/ {print $7}'))

stride=0.01

# echo "osd primary affinity"
# echo ${osd_pri_aff[@]}

# echo "print pool list"
# echo ${pool_id_list[@]}

# echo "print osd list"
# echo ${osd_list[@]}

# get primary pg numbers by osd of the pool
get_pri_pgs()
{
	pri_pgs_by_osd=($(ceph pg dump | awk -v pool_id="$pool_id" '
BEGIN {
   IGNORECASE = 1 
}
# get column of primary pg num
/^PG_STAT/ { 
  prim_col=1;
  while($prim_col!="UP_PRIMARY") {
    prim_col++
  }
  prim_col++;
}

/^[0-9a-f]+\.[0-9a-f]+/ { 
  match($0,/^[0-9a-f]+/); 
  pool=substr($0,RSTART,RLENGTH); 
  poollist[pool]=0;
  up_primary=$prim_col;
  j=0;
  RSTART=0; 
  RLENGTH=0; 
  delete prim_osds;

  # primary pg
  while(match(up_primary,/[0-9]+/)>0) {
    prim_osds[++j]=substr(up_primary,RSTART,RLENGTH);
    up_primary=substr(up_primary,RSTART+RLENGTH);
  }

  for(j in prim_osds) {
    prim_array[prim_osds[j],pool]++;
    prim_osdlist[prim_osds[j]];
  }
}

END {
  sum=0; count=0;
  # print primary pg num
  for (i in prim_osdlist) { 
	  sum+=prim_array[i,pool_id];
	  count++;
      print(prim_array[i,pool_id]); 
  } 
  print(sum);
  for (i in prim_osdlist) {
	  print(i);
  }
}
'))

	# echo ${pri_pgs_by_osd[@]}
	max=${pri_pgs_by_osd[0]}
	min=${pri_pgs_by_osd[1]}

	count=${#pri_pgs_by_osd[@]}
	count=$[count/2]
	sum=${pri_pgs_by_osd[$count]}
	average=$[sum/count]
}

for (( j=0; j<$iter_times; j++ )); do
	get_pri_pgs
	counter=0
	diff_sum=0
	for i in ${pri_pgs_by_osd[@]}; do
		if [[ $counter -eq $count ]]; then
			break
		fi
		if [[ $max -lt $i ]]; then
			max=$i
		fi
		if [[ $min -gt $i ]]; then
			min=$i
		fi
		tmp_aff=${osd_pri_aff[pri_pgs_by_osd[$[counter+count+1]]]}
		if [[ $i -lt $average && $(echo ${tmp_aff%.*}) -ne 1 ]]; then
			tmp_aff=$(echo "ibase=10; scale=2; $tmp_aff+$stride" | bc)
		fi
		if [[ $i -gt $average ]]; then
			tmp_aff=$(echo "ibase=10; scale=2; $tmp_aff-$stride" | bc)
		fi
		osd_pri_aff[pri_pgs_by_osd[$[counter+count+1]]]=$tmp_aff
		let counter++
		diff=$(echo "ibase=10; scale=2; $i-$average" | bc)
		abs_diff=$(echo $diff | awk ' { if($1>=0) { print $1} else {print $1*-1 }}')
		diff_sum=$(echo "ibase=10; scale=2; $diff_sum+$abs_diff" | bc)
	done
	deviation=$(echo "ibase=10; scale=2; $diff_sum/$count" | bc)
	if [[ $(echo "$deviation<$set_dev") = 1 ]]; then
		break
	fi
	# adjust osd primary affinity
	for i in ${osd_list[@]}; do
		ceph osd primary-affinity $i ${osd_pri_aff[i]}
		echo $i
	done
done

echo "max:$max"
echo "min:$min"
echo "deviation:$deviation"
echo "average:$average"
echo "sum:$sum"
#echo "count:$count"
#echo ${osd_pri_aff[@]}
