Some Flightplan-related experiments were carried out on virtual networks that instantiate the
"fat-tree" network topology described in the SIGCOMM 2008 paper:
[A Scalable, Commodity Data Center Network Architecture](http://cseweb.ucsd.edu/~vahdat/papers/sigcomm08.pdf).

This repo includes a P4+BMv2+FDP implementation of this topology -- that is,
featuring P4 switches using the BMv2 runtime and using the FDP backend for
instantiating Mininet and configuring the virtual network.

The implementation consists of 2 parts:
1. [Topology and configuration generator](../generate_alv_network.py). We have several examples based on the topology instance where [k=4](../bmv2/topologies/alv_k\=4.yml).
2. [Routing program](../Source/ALV.p4) that is embedded in other P4 programs wanting to use this topology.
