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

ceph pg dump | awk '
BEGIN {
   IGNORECASE = 1 
}
/^PG_STAT/ { 
  # get column of primary pg num
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
  delete sumpool;
  # print primary pg num
  printf("\n");
  printf("=====Primary PG Sum by OSD=====\n");
  printf("pool :\t"); 
  for (i in poollist) 
    printf("%s\t",i); 
  printf("| SUM \n");
  for (i in poollist) 
    printf("--------"); 

  printf("----------------\n");

  for (i in prim_osdlist) { 
    printf("osd.%i\t", i); 
    sum=0;
    for (j in poollist) { 
      printf("%i\t", prim_array[i,j]); 
      sum+=prim_array[i,j]; 
      sumpool[j]+=prim_array[i,j] 
    }; 
    printf("| %i\n",sum) 
  }

  for (i in poollist) 
    printf("--------"); 

  printf("----------------\n");

  printf("SUM :\t"); 

  for (i in poollist) 
    printf("%s\t",sumpool[i]); 

  printf("|\n");
}
'
