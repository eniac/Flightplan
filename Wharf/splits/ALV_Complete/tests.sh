#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# FIXME various hardcoded paths
# FIXME this and other scripts assume that it's being run in the "Wharf" directory
# FIXME poor naming choices for tests

TOPOLOGY=$WHARF_REPO/splits/ALV_Complete/alv_k=4.yml
MODES=(autotest autotest_long interactive_complete complete_fec_e2e complete_mcd_e2e)
DEFAULT_MODE=autotest

if [ -z "${MODE}" ]
then
  MODE=$DEFAULT_MODE
  echo "Using default MODE from $0"
fi

function interactive_complete {
  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
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

  FEC_INIT_PCAP=$WHARF_REPO/bmv2/pcaps/lldp_enable_fec.pcap

  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
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

  FEC_INIT_PCAP=$WHARF_REPO/bmv2/pcaps/lldp_enable_fec.pcap
  TRAFFIC_PREINPUT=$WHARF_REPO/bmv2/pcaps/tcp_100.pcap
  TRAFFIC_INPUT=/tmp/tcp_100.pcap
  CACHEFILE=/tmp/tcprewrite_cachefile
  # Traffic will be sent from p0h0 to p1h0
  tcpprep --auto=first --pcap=${TRAFFIC_PREINPUT} --cachefile=${CACHEFILE}
  tcprewrite --endpoints=192.0.0.2:192.1.0.2 --cachefile=${CACHEFILE} -i ${TRAFFIC_PREINPUT} -o ${TRAFFIC_INPUT}

  sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
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

  # Creating graph log file
  GRAPH_LOG=$LOG_DUMPS/graph_log.txt
  echo "Using GRAPH LOG = ${GRAPH_LOG}"
  touch ${GRAPH_LOG}
  > ${GRAPH_LOG}
	
  # Creating empty temp file
  TEMP=$LOG_DUMPS/temp.txt
  echo "Using TEMP = ${TEMP}"
  touch ${TEMP}
  > ${TEMP}

  # Take the tcp dump to temp file
  tcpdump -xx -r ${PCAP_DUMPS}/p0h0_to_p0e0.pcap > ${TEMP}

  # First packet time is a reference time to calculate the elapsed time of all the packets
  time=$(head -n 1 ${TEMP})
  readarray -d " " -t time_stream <<< ${time}

  awk -v BASE="${time_stream[0]}" '{ 
    if(/length/){
    split(BASE, base_time_array, /[:.]/)
    split($1, time_array, /[:.]/) 
    elapsed_time=(time_array[1] - base_time_array[1])*60*60*1000*1000 + (time_array[2] - base_time_array[2])*60*1000*1000 + (time_array[3] - base_time_array[3])*1000*1000 + time_array[4] - base_time_array[4]
      printf "%s ", elapsed_time
      
      getline
      getline
      getline
      
      if(seq_count[$5$6]+0 > 0){
        retransmission_count++
      }
      seq_count[$5$6]++
      printf "%d\n", retransmission_count+0 
    }
  }' ${TEMP} > ${GRAPH_LOG}

  rm ${TEMP}

  if [[ $? == 0 ]]
  then
      echo "Test succeeded"
      exit 0
  else
      echo "Test failed"
      exit 1
  fi
}

function complete_mcd_e2e {
  # Based on bmv2/complete_mcd_e2e.sh

  FEC_INIT_PCAP=$WHARF_REPO/bmv2/pcaps/lldp_enable_fec.pcap
  PCAP_TOOLS=$WHARF_REPO/bmv2/pcap_tools/

  TRAFFIC_PREINPUT=$WHARF_REPO/bmv2/pcaps/Memcached_in_short.pcap

  SIP="192.0.0.2"
  DIP="192.1.0.2"
  SMAC="02:00:00:d8:c2:6b"
  DMAC="02:00:00:9c:a8:79"

  INPUT_PCAP=$OUTDIR/${BASENAME}_in.pcap
  echo "Putting pcap in $INPUT_PCAP"
  python2 ${PCAP_TOOLS}/pcap_sub.py $TRAFFIC_PREINPUT $INPUT_PCAP\
      --sip="$SIP" --dip="$DIP" --smac="$SMAC" --dmac="$DMAC"

  sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": tcpreplay -i dropper-eth0 ${FEC_INIT_PCAP}" \
     --fg-host-prog ": tcpreplay -i dropper-eth1 ${FEC_INIT_PCAP}" \
     --fg-host-prog "p1h0: memcached -u $USER -U 11211 -B ascii -vv &" \
     --fg-host-prog "p0h0: tcpreplay -i p0h0-eth1 --pps=10 ${INPUT_PCAP}" \
          2> $LOG_DUMPS/flightplan_mininet_log.err

  # FIXME The target log's name might change -- this is brittle!
  TARGET_LOG=${LOG_DUMPS}/p1h0_prog_18.log
  echo "Using TARGET_LOG=`ls -lh ${TARGET_LOG}`"

  grep --text -E '^[<>]' ${TARGET_LOG} | grep --text -v "server" | grep --text -v "buffer" | sed -E 's/^([<>])[0-9]+/\1/' | grep --text -v STORED | grep --text -v "sending key" | grep --text -v END > ${LOG_DUMPS}/mcd_log

  diff -q <(sort ${LOG_DUMPS}/mcd_log) <(sort $WHARF_REPO/mcd_log_withoutcache.expected)
  if [[ $? == 0 ]]
  then
      echo "Test conclusive: cache was NOT used"
      exit 0
  fi

  diff -q <(sort ${LOG_DUMPS}/mcd_log) <(sort $WHARF_REPO/mcd_log_withcache.expected)
  if [[ $? == 0 ]]
  then
      echo "Test conclusive: cache was used"
      exit 0
  fi

  echo "Test inconclusive"
  exit 1
}

source `dirname "$0"`/../../run_alv.sh
