This relies on send.py and myTunnel_header.py which were copied from the basic_tunnel P4 tutorial.

## Running
```
MODE=bt_experiment_base ./tests.sh
MODE=bt_experiment_encapsulated ./tests.sh
```

## Correctness
Look at forward paths to check that the tunneled packets are following the path for that tunnel.
The normal routing follows this path:
  p0h3 -> p0e1 -> p0a1 -> c3 -> p3a1 -> p3e1 -> p3h2
but the tunnel (`--dst_id 1`) is preset to follow this path:
  p0h3 -> p0e1 -> p0a0 -> c0 -> p1a0 -> c1 -> p3a0 -> p3e0 -> p3a1 -> p3e1 -> p3h2

We can confirm that the recipient is receiving the tunneled traffic:
```
~/Documents/Flightplan/P4Boosters/Wharf/splits3/ALV_bt$ tcpdump -nXXSvr test_output/alv_k\=4/pcap_dump/p3e1_to_p3h2.pcap | head
reading from file test_output/alv_k=4/pcap_dump/p3e1_to_p3h2.pcap, link-type EN10MB (Ethernet)
12:02:49.826292 02:00:00:cf:e6:4f > ff:ff:ff:ff:ff:ff, ethertype Unknown (0x1212), length 55: 
        0x0000:  ffff ffff ffff 0200 00cf e64f 1212 0800  ...........O....
        0x0010:  0001 4500 0025 0001 0000 4000 f8cf c000  ..E..%....@.....
        0x0020:  0103 c003 0102 466c 6967 6874 706c 616e  ......Flightplan
        0x0030:  2074 6573 7420 31                        .test.1
12:02:51.194254 02:00:00:cf:e6:4f > ff:ff:ff:ff:ff:ff, ethertype Unknown (0x1212), length 55: 
        0x0000:  ffff ffff ffff 0200 00cf e64f 1212 0800  ...........O....
        0x0010:  0001 4500 0025 0001 0000 4000 f8cf c000  ..E..%....@.....
        0x0020:  0103 c003 0102 466c 6967 6874 706c 616e  ......Flightplan
        0x0030:  2074 6573 7420 32                        .test.2
tcpdump: Unable to write output: Broken pipe
```
