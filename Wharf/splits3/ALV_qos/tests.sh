#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, August 2020
#
# FIXME this and other scripts assume that it's being run in the "Wharf" directory

if [ -z "${TOPOLOGY}" ]
then
  export TOPOLOGY=$WHARF_REPO/splits3/ALV_qos/alv_k=4.yml
  echo "Using default TOPOLOGY from $0: ${TOPOLOGY}"
else
  echo "Using inherited TOPOLOGY: ${TOPOLOGY}"
fi

if [ -z "${EXPERIMENT_INIT}" ]
then
  export EXPERIMENT_INIT=true
  echo "Using default EXPERIMENT_INIT from $0: ${EXPERIMENT_INIT}"
else
  echo "Using inherited EXPERIMENT_INIT: ${EXPERIMENT_INIT}"
fi

MODES=(qos_experiment)
DEFAULT_MODE=qos_experiment

if [ -z "${MODE}" ]
then
  MODE=$DEFAULT_MODE
  echo "Using default MODE from $0: ${MODE}"
fi

function qos_experiment {
  if [ -z "${NUM_PINGS}" ]
  then
    NUM_PINGS=30
  fi

  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": ${EXPERIMENT_INIT}" \
     --host-prog "p0h0: iperf3 -s -B 192.0.0.2 -p 5201" \
     --host-prog "p0h1: iperf3 -s -B 192.0.0.3 -p 5201" \
     --host-prog "p0h2: iperf3 -s -B 192.0.1.2 -p 5201" \
     --host-prog "p0h3: iperf3 -s -B 192.0.1.3 -p 5201" \
     --host-prog "p1h0: iperf3 -s -B 192.1.0.2 -p 5201" \
     --host-prog "p1h1: iperf3 -s -B 192.1.0.3 -p 5201" \
     --host-prog "p1h2: iperf3 -s -B 192.1.1.2 -p 5201" \
     --host-prog "p1h3: iperf3 -s -B 192.1.1.3 -p 5201" \
     --host-prog "p2h0: iperf3 -s -B 192.2.0.2 -p 5201" \
     --host-prog "p2h1: iperf3 -s -B 192.2.0.3 -p 5201" \
     --host-prog "p2h2: iperf3 -s -B 192.2.1.2 -p 5201" \
     --host-prog "p2h3: iperf3 -s -B 192.2.1.3 -p 5201" \
     --host-prog "p3h0: iperf3 -s -B 192.3.0.2 -p 5201" \
     --host-prog "p3h1: iperf3 -s -B 192.3.0.3 -p 5201" \
     --host-prog "p3h2: iperf3 -s -B 192.3.1.2 -p 5201" \
     --host-prog "p3h3: iperf3 -s -B 192.3.1.3 -p 5201" \
     --fg-host-prog "p0h3: hping3 -c $NUM_PINGS -S -p 5201 192.3.1.2" \
     --fg-host-prog "p0h3: hping3 -c $NUM_PINGS -S -p 5201 192.3.1.2" \
     --fg-host-prog "p0h3: hping3 -c $NUM_PINGS -S -p 5201 192.3.1.2" \
     --fg-host-prog "p0h3: hping3 -c $NUM_PINGS -S -p 5201 192.3.1.2" \
     --fg-host-prog "p0h3: hping3 -c $NUM_PINGS -S -p 5201 192.3.1.2" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
     # where:
     #   p0h3 = 192.0.1.3
     #   p3h2 = 192.3.1.2
}

source `dirname "$0"`/../../run_alv.sh
