# Ceph Tools

Several tools to help deploy ceph easily and count pg number by OSD.

# print pg number by osd

```
$ cd osd_tools
$ ./print_pgnum_by_osd.sh
```

You can get pg sum by osd and primary pg sum by osd:

```
OSD STATUS
15 osds: 15 up, 15 in; epoch: e217
dumped all
=====PG Sum by OSD=====
pool :  2       3       | SUM
--------------------------------
osd.4   101     101     | 202
osd.5   101     99      | 200
osd.6   99      101     | 200
osd.7   101     99      | 200
osd.8   101     99      | 200
osd.9   101     101     | 202
osd.10  101     101     | 202
osd.11  99      99      | 198
osd.12  101     99      | 200
osd.0   99      100     | 199
osd.13  101     101     | 202
osd.1   99      99      | 198
osd.14  98      101     | 199
osd.2   99      99      | 198
osd.3   99      101     | 200
--------------------------------
SUM :   1500    1500    |

=====Primary PG Sum by OSD=====
pool :  2       3       | SUM
--------------------------------
osd.4   37      44      | 81
osd.5   31      35      | 66
osd.6   29      31      | 60
osd.7   25      35      | 60
osd.8   37      34      | 71
osd.9   37      35      | 72
osd.10  30      28      | 58
osd.11  37      30      | 67
osd.12  31      35      | 66
osd.13  34      27      | 61
osd.0   38      36      | 74
osd.14  33      26      | 59
osd.1   28      39      | 67
osd.2   43      31      | 74
osd.3   30      34      | 64
--------------------------------
SUM :   500     500     |
```
