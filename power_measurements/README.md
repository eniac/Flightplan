# Power control and check
If a target is unresponsive you can check whether it's powered from the socket:
```
nsultana@tclust8:~$ ./get_state.sh dcomp1
dcomp1 (192.168.1.108): 	ON
```
If a target is `OFF` then you can power it on using the following command:
```
nsultana@tclust8:~$ ./power_on.sh dcomp1
```
Sockets are known to occasionally decide that a target should be powered off, so the above scripts can help ascertain this and correct it.

You might get different replies however -- indicating that the socket itself might be unresponsive and/or malfunctioning:
```
nsultana@tclust8:~$ ./get_state.sh tclust4
tclust4 (192.168.1.110): 	timeout
nsultana@tclust8:~$ ./get_state.sh tclust2
tclust2 (192.168.1.111): 	8
```
If you see those replies, then it's likely that the socket needs resetting and possibly reconfiguring or replacement; unfortunately this can only be done manually.

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
