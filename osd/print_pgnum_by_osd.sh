#!/bin/bash

# print osd status 
echo "OSD STATUS"
ceph osd stat
ceph pg dump | awk '
BEGIN {
   IGNORECASE = 1 
}
/^PG_STAT/ { 
  # get column of pg num
  col=1; 
  while($col!="UP") {
    col++
  }; 
  col++ 
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
  up=$col;
  up_primary=$prim_col;
  i=0; j=0;
  RSTART=0; 
  RLENGTH=0; 
  delete osds;
  delete prim_osds;

  # whole pg
  while(match(up,/[0-9]+/)>0) {
    osds[++i]=substr(up,RSTART,RLENGTH); 
    up=substr(up, RSTART+RLENGTH) 
  }

  for(i in osds) {
    array[osds[i],pool]++; 
    osdlist[osds[i]];
  }

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
  # print the whole pg num
  printf("=====PG Sum by OSD=====\n");
  printf("pool :\t"); 
  for (i in poollist) 
    printf("%s\t",i); 

  printf("| SUM \n");

  for (i in poollist) 
    printf("--------"); 

  printf("----------------\n");

  for (i in osdlist) { 
    printf("osd.%i\t", i); 
    sum=0;
    for (j in poollist) { 
      printf("%i\t", array[i,j]); 
      sum+=array[i,j]; 
      sumpool[j]+=array[i,j] 
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
