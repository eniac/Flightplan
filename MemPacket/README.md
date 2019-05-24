# Memcached FPGA Testing

## Generate packets
Use scripts `./generate_packets.sh` to generate testing packets and standard response from actual memcached service. The length of KEY and DATA could be modified in config file `memaslap.cnf`

## C-simulation
Run `./runUnitTests.sh` to run all unit tests. Or run `UnitTest\Testx\test.sh` individually.
## Hardware testing
Run `./fpgaUnitTests.sh $interface` where `$interface` should specify the interface used.
## Test cases
| ﻿      |  Pkts sent in order                         | Recv@Server(DstPort 11211) | Recv@Client (SrcPort 11211) | Behaviour Description                            |
|-------|-----------------------------------|-------------------------|--------------------------|--------------------------------------------------|
| Test1 | Set Pkts                          | Forward set pkts        |                          | Set pkts forwarded and Store the entries locally |
|       | Get Pkts                          |                         | VALUE pkts               |                                                  |
| Test2 | Single Get Pkt (Key A)            | Forward get pkt         |                          | Get Miss: Forward the request to Server          |
|       | Single Value Pkt (Key A)          |                         | VALUE pkt                | Forward VALUE Pkts and Store the entry locally   |
|       | Single Get Pkt (Key A)            |                         | VALUE pkt                | The entry should be saved and no more miss       |
| Test3 | Store Pkt                         |                         | Forward Store Pkt        | Server acknoledeged the Set.                     |
| Test4 | Set Pkt (Key A)                   | Forward set pkt         |                          |                                                  |
|       | Set Pkt(Key B but with same hash) | Forward set pkt         |                          | Collision: kick the previous entry               |
|       | Get Pkt (Key A)                   | Forward get pkt         |                          | Hash collision: Forward the request to Server    |
|       | Get Pkt(Key B)                    |                         | VALUE pkt                | Not Miss                                         |

## Add Test Cases
The `Test` Folder should contain the `pcap/Send.pcap` and `pcap/ref@client.pcap` and `pcap/ref@server.pcap`

## CheckSum
The `UnitTest\testscripts\cleanPcap.py` is used to clean the UDP checksum to 0. All packets for comparision must be set the `udp.checksum` to 0. 

## TODO
Add `ip.checksum` into implementation.


