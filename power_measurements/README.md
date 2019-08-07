# Logs
Logs are gathered on **tclust8** in the directory `/home/nsultana` and
follow this naming scheme:
```
power_0.out
power_1.out
power_2.out
power_3.out
power_4.out
power_5.out
power_6.out
power_7.out
```
Each file logs the power readings of a single device.

Files are structured as entries consisting of a timestamp, name of the device and its IP address, and the power measure at that instant:
```
nsultana@tclust8:~$ tail power_1.out
2019-08-07 01:01:04.632514648+00:00 dcomp1 (192.168.1.108): 106.525
2019-08-07 01:01:04.806663560+00:00 dcomp1 (192.168.1.108): 106.340
2019-08-07 01:01:04.982379850+00:00 dcomp1 (192.168.1.108): 106.340
2019-08-07 01:01:05.157009762+00:00 dcomp1 (192.168.1.108): 106.340
2019-08-07 01:01:05.334423681+00:00 dcomp1 (192.168.1.108): 106.340
2019-08-07 01:01:05.518685561+00:00 dcomp1 (192.168.1.108): 106.340
2019-08-07 01:01:05.691558566+00:00 dcomp1 (192.168.1.108): 106.325
2019-08-07 01:01:05.880317646+00:00 dcomp1 (192.168.1.108): 106.325
2019-08-07 01:01:06.055528072+00:00 dcomp1 (192.168.1.108): 106.325
2019-08-07 01:01:06.232763128+00:00 dcomp1 (192.168.1.108): 106.325
```

# Graphing
```
$ cat power_1.out | python graph.py
Done for dcomp1
```

# TODO
Describe the scripts that generate the logs, how to start them up, etc
