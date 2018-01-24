### cpu boosters###

- pcaps/* -- iperf pcaps. iperfClient2Server and iperfServer2Client are unmodified pcaps. tofinoProcessed_*.pcap have FEC header added after ethernet header and added parity packets. (K = H = 3)

- runTofinoModel.sh <input_pcap> -- replays input_pcap into a model of the tofino that adds fec headers and parity packets. Configurable K and H in script.

- runEmptyBooster.sh <input_pcap> -- runs the empty booster with input_pcap and dumps output packets to boosterProcessed_<input_pcap>.

- genIperfPcap.sh -- script for source pcap generatiom. 

- fecDefs.h -- struct definition for FEC header.
