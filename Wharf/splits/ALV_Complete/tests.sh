#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# FIXME various hardcoded paths
# FIXME poor naming choices for tests

TOPOLOGY=splits/ALV_Complete/alv_k=4.yml
MODES=(autotest autotest_long interactive_complete complete_fec_e2e)
DEFAULT_MODE=autotest

if [ -z "${MODE}" ]
then
  MODE=$DEFAULT_MODE
  echo "Using default MODE from $0"
fi

function interactive_complete {
  sudo -E python bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --cli
}

function autotest {
  if [ -z "${NUM_PINGS}" ]
  then
    NUM_PINGS=1
  fi

  FEC_INIT_PCAP=/home/nsultana/2/P4Boosters/Wharf/bmv2/pcaps/lldp_enable_fec.pcap

  sudo -E python bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": tcpreplay -i dropper-eth0 ${FEC_INIT_PCAP}" \
     --fg-host-prog ": tcpreplay -i dropper-eth1 ${FEC_INIT_PCAP}" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p0h0: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p0h1: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p0h2: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p0h3: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p1h0: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p1h1: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p1h2: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p1h3: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p2h0: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p2h1: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p2h2: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p2h3: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p3h0: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p3h1: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p3h2: ping -c $NUM_PINGS 192.3.1.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.0.0.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.0.0.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.0.1.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.0.1.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.1.0.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.1.0.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.1.1.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.1.1.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.2.0.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.2.0.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.2.1.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.2.1.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.3.0.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.3.0.3" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.3.1.2" \
     --fg-host-prog "p3h3: ping -c $NUM_PINGS 192.3.1.3" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest_long {
  NUM_PINGS=10
  autotest
}

function complete_fec_e2e {
  # Based on bmv2/complete_fec_e2e.sh

  FEC_INIT_PCAP=/home/nsultana/2/P4Boosters/Wharf/bmv2/pcaps/lldp_enable_fec.pcap
  TRAFFIC_PREINPUT=/home/nsultana/2/P4Boosters/Wharf/bmv2/pcaps/tcp_100.pcap
  TRAFFIC_INPUT=/tmp/tcp_100.pcap
  CACHEFILE=/tmp/tcprewrite_cachefile
  # Traffic will be sent from p0h0 to p1h0
  tcpprep --auto=first --pcap=${TRAFFIC_PREINPUT} --cachefile=${CACHEFILE}
  tcprewrite --endpoints=192.0.0.2:192.1.0.2 --cachefile=${CACHEFILE} -i ${TRAFFIC_PREINPUT} -o ${TRAFFIC_INPUT}

  sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

  sudo -E python bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": tcpreplay -i dropper-eth0 ${FEC_INIT_PCAP}" \
     --fg-host-prog ": tcpreplay -i dropper-eth1 ${FEC_INIT_PCAP}" \
     --fg-host-prog "p0h0: tcpreplay -i p0h0-eth1 ${TRAFFIC_INPUT}" \
          2> $LOG_DUMPS/flightplan_mininet_log.err

  mv ${TRAFFIC_INPUT} ${PCAP_DUMPS}/
  mv ${CACHEFILE} ${PCAP_DUMPS}/

  TRAFFIC_INPUT=${PCAP_DUMPS}/`basename ${TRAFFIC_INPUT} `

  diff <(tcpdump -r ${PCAP_DUMPS}/p1e0_to_p1h0.pcap -XX -S -vv | grep -v " IP (tos " | grep -v 0x0010 | grep -v 0x0000 | grep -v ": Flags" | sort | uniq) <(tcpdump -r ${TRAFFIC_INPUT} -XX -S -vv | grep -v " IP (tos " | grep -v 0x0010 | grep -v 0x0000 | grep -v ": Flags" | sort | uniq)
  if [[ $? == 0 ]]
  then
      echo "Test succeeded"
      exit 0
  else
      echo "Test failed"
      exit 1
  fi
}

source `dirname "$0"`/../../run_alv.sh
