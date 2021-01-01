# Info
This example adapts the
[qos](https://github.com/p4lang/tutorials/tree/master/exercises/qos)
example from the P4 tutorial to run in the [ALV topology](../../ALV/README.md).

**See also**: a [split](../ALV_qos_hl3new) variant of this program.

## What you see
Packets are sent from p0h3 and their `tos` field is initially `0x0`.
In the network, the `tos` field is changed to `0xb0` because of the types of packets being sent.


# Code

## Running
```
./tests.sh
```


## Correctness
Initially `tos` is `0x0`:
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_qos$ tcpdump -nSvr test_output/alv_k\=4/pcap_dump/p0h3_to_p0e1.pcap | head
reading from file test_output/alv_k=4/pcap_dump/p0h3_to_p0e1.pcap, link-type EN10MB (Ethernet)
09:33:48.843240 IP (tos 0x0, ttl 64, id 10137, offset 0, flags [none], proto TCP (6), length 40)
    192.0.1.3.2110 > 192.3.1.2.5201: Flags [S], cksum 0xb881 (correct), seq 1919893040, win 512, length 0
09:33:48.856195 IP (tos 0xb0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 40)
    192.0.1.3.2110 > 192.3.1.2.5201: Flags [R], cksum 0x60a8 (correct), seq 1919893041, win 0, length 0
09:33:49.843682 IP (tos 0x0, ttl 64, id 1226, offset 0, flags [none], proto TCP (6), length 40)
    192.0.1.3.2111 > 192.3.1.2.5201: Flags [S], cksum 0xc1d5 (correct), seq 1302174641, win 512, length 0
09:33:49.853448 IP (tos 0xb0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 40)
    192.0.1.3.2111 > 192.3.1.2.5201: Flags [R], cksum 0x27f8 (correct), seq 1302174642, win 0, length 0
09:33:50.844740 IP (tos 0x0, ttl 64, id 36242, offset 0, flags [none], proto TCP (6), length 40)
    192.0.1.3.2112 > 192.3.1.2.5201: Flags [S], cksum 0x6571 (correct), seq 181364438, win 512, length 0
```

Ignore the Reset packets, with `tos` set to `0xb0`, they're because of the hping3-reply:
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_qos$ tcpdump -nSvr test_output/alv_k\=4/pcap_dump/p0e1_to_p0h3.pcap | head
reading from file test_output/alv_k=4/pcap_dump/p0e1_to_p0h3.pcap, link-type EN10MB (Ethernet)
09:33:48.856180 IP (tos 0xb0, ttl 59, id 0, offset 0, flags [DF], proto TCP (6), length 44)
    192.3.1.2.5201 > 192.0.1.3.2110: Flags [S.], cksum 0x7c83 (correct), seq 263395139, ack 1919893041, win 42340, options [mss 1460], length 0
09:33:49.853435 IP (tos 0xb0, ttl 59, id 0, offset 0, flags [DF], proto TCP (6), length 44)
    192.3.1.2.5201 > 192.0.1.3.2111: Flags [S.], cksum 0x5951 (correct), seq 1271186867, ack 1302174642, win 42340, options [mss 1460], length 0
09:33:50.854347 IP (tos 0xb0, ttl 59, id 0, offset 0, flags [DF], proto TCP (6), length 44)
    192.3.1.2.5201 > 192.0.1.3.2112: Flags [S.], cksum 0x1b47 (correct), seq 3215656831, ack 181364439, win 42340, options [mss 1460], length 0
09:33:51.856763 IP (tos 0xb0, ttl 59, id 0, offset 0, flags [DF], proto TCP (6), length 44)
    192.3.1.2.5201 > 192.0.1.3.2113: Flags [S.], cksum 0xc524 (correct), seq 1619451755, ack 321731539, win 42340, options [mss 1460], length 0
09:33:52.857052 IP (tos 0xb0, ttl 59, id 0, offset 0, flags [DF], proto TCP (6), length 44)
    192.3.1.2.5201 > 192.0.1.3.2114: Flags [S.], cksum 0x8d9d (correct), seq 1216642609, ack 222032519, win 42340, options [mss 1460], length 0
```

We can see the Syn packets have `tos` set to `0xb0` by the time they arrive at p3h2:
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_qos$ tcpdump -nSvr test_output/alv_k\=4/pcap_dump/p3e1_to_p3h2.pcap | head
reading from file test_output/alv_k=4/pcap_dump/p3e1_to_p3h2.pcap, link-type EN10MB (Ethernet)
09:33:48.850102 IP (tos 0xb0, ttl 59, id 10137, offset 0, flags [none], proto TCP (6), length 40)
    192.0.1.3.2110 > 192.3.1.2.5201: Flags [S], cksum 0xb881 (correct), seq 1919893040, win 512, length 0
09:33:48.860880 IP (tos 0xb0, ttl 59, id 0, offset 0, flags [DF], proto TCP (6), length 40)
    192.0.1.3.2110 > 192.3.1.2.5201: Flags [R], cksum 0x60a8 (correct), seq 1919893041, win 0, length 0
09:33:49.848561 IP (tos 0xb0, ttl 59, id 1226, offset 0, flags [none], proto TCP (6), length 40)
    192.0.1.3.2111 > 192.3.1.2.5201: Flags [S], cksum 0xc1d5 (correct), seq 1302174641, win 512, length 0
09:33:49.858135 IP (tos 0xb0, ttl 59, id 0, offset 0, flags [DF], proto TCP (6), length 40)
    192.0.1.3.2111 > 192.3.1.2.5201: Flags [R], cksum 0x27f8 (correct), seq 1302174642, win 0, length 0
09:33:50.849656 IP (tos 0xb0, ttl 59, id 36242, offset 0, flags [none], proto TCP (6), length 40)
    192.0.1.3.2112 > 192.3.1.2.5201: Flags [S], cksum 0x6571 (correct), seq 181364438, win 512, length 0
tcpdump: Unable to write output: Broken pipe
```


## Performance
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_qos$ head -5 test_output/alv_k=4/log_files/p0h3_prog_19.log test_output/alv_k=4/log_files/p0h3_prog_20.log test_output/alv_k=4/log_files/p0h3_prog_21.log test_output/alv_k=4/log_files/p0h3_prog_22.log test_output/alv_k=4/log_files/p0h3_prog_23.log
==> test_output/alv_k=4/log_files/p0h3_prog_19.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 9.4/24.3/230.7 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_20.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 8.9/27.1/414.1 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_21.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 9.1/28.8/472.1 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_22.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 10.0/15.8/57.2 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_23.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 8.9/13.7/21.2 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes
```

Averaging:
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_qos$ echo "scale=3; (24.3 + 27.1 + 28.8 + 15.8 + 13.7) / 5" | bc
21.940
```

In comparison, using the disaggregated version of the program:
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_qos_hl3new$ head -5 test_output/alv_k=4/log_files/p0h3_prog_19.log test_output/alv_k=4/log_files/p0h3_prog_20.log test_output/alv_k=4/log_files/p0h3_prog_21.log test_output/alv_k=4/log_files/p0h3_prog_22.log test_output/alv_k=4/log_files/p0h3_prog_23.log
==> test_output/alv_k=4/log_files/p0h3_prog_19.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 12.9/17.2/25.1 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_20.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 13.1/50.3/1015.6 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_21.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 12.6/15.9/18.6 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_22.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 12.4/19.6/130.4 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes

==> test_output/alv_k=4/log_files/p0h3_prog_23.log <==

--- 192.3.1.2 hping statistic ---
30 packets transmitted, 30 packets received, 0% packet loss
round-trip min/avg/max = 12.9/15.8/21.2 ms
HPING 192.3.1.2 (p0h3-eth1 192.3.1.2): S set, 40 headers + 0 data bytes
```

Averaging:
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_qos$ echo "scale=3; (17.2 + 50.3 + 15.9 + 19.6 + 15.8) / 5" | bc
23.760
```

This is of course a very crude comparison and not necessarily reflective of
performance on hardware, but as far as comparing the two experiment runs the
disaggregated version imposes an RTT overhead of 8.2%:
```
echo "scale=3; (23.760 - 21.940) / 21.940" | bc
.082
```
