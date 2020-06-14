#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# FIXME various hardcoded paths
# FIXME poor naming choices for tests

HERE=`pwd`

if [ -z "${TOPOLOGY}" ]
then
     TOPOLOGY=$HERE/alv_k=4.yml
fi
echo "Using TOPOLOGY=${TOPOLOGY}"

COLON=": "
TESTDIR=$HERE/test_output
BASENAME=$(basename $TOPOLOGY .yml)
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
START_PROG=$HERE/start.sh
STEP1_PROG=$HERE/step1.sh
STEP2_PROG=$HERE/step2.sh
STEP3_PROG=$HERE/step3.sh
START2_PROG=$HERE/start2.sh
AUTO2STEP1_PROG=$HERE/autotest2_step1.sh
AUTO2STEP2_PROG=$HERE/autotest2_step2.sh
AUTO2STEP3_PROG=$HERE/autotest2_step3.sh
START2_PROG=$HERE/start3.sh
END_PROG=$HERE/end.sh
AUTO2STEP1B_PROG=$HERE/autotest2_step1B.sh
AUTO2STEP2B_PROG=$HERE/autotest2_step2B.sh
AUTO2STEP3B_PROG=$HERE/autotest2_step3B.sh
MODES=(demo1 autotest1 autotest2 autotest2B autotest_long autotest3B)

if [ -z "${MODE}" ]
then
  MODE=autotest2B
  echo "Using default MODE from $0"
fi

function demo1 {
  sudo -E python ../../bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog "p0h0: ping -c 1 192.0.0.2" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
     --fg-host-prog ": $START_PROG" \
     --fg-host-prog "p0h0: ping -c 1 192.0.0.2" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest1 {

  sudo -E python ../../bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": $START_PROG" \
     --fg-host-prog "p0h0: ping -c 13 192.0.1.2" \
     --fg-host-prog ": $STEP1_PROG" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": $STEP2_PROG" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": $STEP3_PROG" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest2 {
  sudo -E python ../../bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": $START_PROG" \
     --fg-host-prog "p0h0: ping -c 13 192.0.1.2" \
     --fg-host-prog ": $AUTO2STEP1_PROG" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
     --fg-host-prog ": $AUTO2STEP2_PROG" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": $AUTO2STEP3_PROG" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest2B {
  sudo -E python ../../bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --host-prog "p0h0: iperf3 -s -B 192.0.0.2" \
     --host-prog "p0h1: iperf3 -s -B 192.0.0.3" \
     --host-prog "p0h2: iperf3 -s -B 192.0.1.2" \
     --host-prog "p0h3: iperf3 -s -B 192.0.1.3" \
     --host-prog "p1h0: iperf3 -s -B 192.1.0.2" \
     --host-prog "p1h1: iperf3 -s -B 192.1.0.3" \
     --host-prog "p1h2: iperf3 -s -B 192.1.1.2" \
     --host-prog "p1h3: iperf3 -s -B 192.1.1.3" \
     --host-prog "p2h0: iperf3 -s -B 192.2.0.2" \
     --host-prog "p2h1: iperf3 -s -B 192.2.0.3" \
     --host-prog "p2h2: iperf3 -s -B 192.2.1.2" \
     --host-prog "p2h3: iperf3 -s -B 192.2.1.3" \
     --host-prog "p3h0: iperf3 -s -B 192.3.0.2" \
     --host-prog "p3h1: iperf3 -s -B 192.3.0.3" \
     --host-prog "p3h2: iperf3 -s -B 192.3.1.2" \
     --host-prog "p3h3: iperf3 -s -B 192.3.1.3" \
     --fg-host-prog ": $START2_PROG" \
     --fg-host-prog ": sleep 1" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p0h0: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p0h1: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p0h2: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p0h3: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p1h0: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p1h1: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p1h2: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p1h3: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p2h0: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p2h1: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p2h2: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p2h3: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p3h0: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p3h1: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p3h2: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.0.0.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.0.0.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.0.1.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.0.1.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.1.0.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.1.0.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.1.1.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.1.1.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.2.0.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.2.0.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.2.1.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.2.1.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.3.0.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.3.0.3" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.3.1.2" \
     --fg-host-prog "p3h3: iperf3 -t 2 -O 1 -c 192.3.1.3" \
     --fg-host-prog ": $END_PROG" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest_long {
  sudo -E python bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --host-prog "p0h0: iperf3 -s -B 192.0.0.2" \
     --host-prog "p0h1: iperf3 -s -B 192.0.0.3" \
     --host-prog "p0h2: iperf3 -s -B 192.0.1.2" \
     --host-prog "p0h3: iperf3 -s -B 192.0.1.3" \
     --host-prog "p1h0: iperf3 -s -B 192.1.0.2" \
     --host-prog "p1h1: iperf3 -s -B 192.1.0.3" \
     --host-prog "p1h2: iperf3 -s -B 192.1.1.2" \
     --host-prog "p1h3: iperf3 -s -B 192.1.1.3" \
     --host-prog "p2h0: iperf3 -s -B 192.2.0.2" \
     --host-prog "p2h1: iperf3 -s -B 192.2.0.3" \
     --host-prog "p2h2: iperf3 -s -B 192.2.1.2" \
     --host-prog "p2h3: iperf3 -s -B 192.2.1.3" \
     --host-prog "p3h0: iperf3 -s -B 192.3.0.2" \
     --host-prog "p3h1: iperf3 -s -B 192.3.0.3" \
     --host-prog "p3h2: iperf3 -s -B 192.3.1.2" \
     --host-prog "p3h3: iperf3 -s -B 192.3.1.3" \
     --fg-host-prog "p0h0: ifconfig" \
     --fg-host-prog "p3h3: ifconfig" \
     --fg-host-prog "p1h0: ifconfig" \
     --fg-host-prog "p2h0: ifconfig" \
     --fg-host-prog ": $START3_PROG" \
     --fg-host-prog ": sleep 1" \
     --fg-host-prog "p0h0: iperf3 -t 600 -O 1 -c 192.3.1.3 &" \
     --fg-host-prog "p1h0: iperf3 -t 600 -O 1 -c 192.2.0.2 &" \
     --fg-host-prog ": sleep 630" \
     --fg-host-prog "p0h0: ifconfig" \
     --fg-host-prog "p3h3: ifconfig" \
     --fg-host-prog "p1h0: ifconfig" \
     --fg-host-prog "p2h0: ifconfig" \
     --fg-host-prog ": $END_PROG" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest3B {
  sudo -E python ../../bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --host-prog "p0h0: iperf3 -s -B 192.0.0.2" \
     --host-prog "p0h1: iperf3 -s -B 192.0.0.3" \
     --host-prog "p0h2: iperf3 -s -B 192.0.1.2" \
     --host-prog "p0h3: iperf3 -s -B 192.0.1.3" \
     --host-prog "p1h0: iperf3 -s -B 192.1.0.2" \
     --host-prog "p1h1: iperf3 -s -B 192.1.0.3" \
     --host-prog "p1h2: iperf3 -s -B 192.1.1.2" \
     --host-prog "p1h3: iperf3 -s -B 192.1.1.3" \
     --host-prog "p2h0: iperf3 -s -B 192.2.0.2" \
     --host-prog "p2h1: iperf3 -s -B 192.2.0.3" \
     --host-prog "p2h2: iperf3 -s -B 192.2.1.2" \
     --host-prog "p2h3: iperf3 -s -B 192.2.1.3" \
     --host-prog "p3h0: iperf3 -s -B 192.3.0.2" \
     --host-prog "p3h1: iperf3 -s -B 192.3.0.3" \
     --host-prog "p3h2: iperf3 -s -B 192.3.1.2" \
     --host-prog "p3h3: iperf3 -s -B 192.3.1.3" \
     --fg-host-prog ": $START3_PROG" \
     --fg-host-prog ": sleep 1" \
     --fg-host-prog "p0h0: iperf3 -t 60 -O 1 -b 1K -c 192.3.1.3 &" \
     --fg-host-prog ": sleep 5" \
     --fg-host-prog ": $AUTO2STEP1B_PROG" \
     --fg-host-prog "p0h0: ping -c 1 192.3.1.3" \
     --fg-host-prog ": sleep 5" \
     --fg-host-prog ": $AUTO2STEP2B_PROG" \
     --fg-host-prog "p0h0: ping -c 1 192.3.1.3" \
     --fg-host-prog ": sleep 10" \
     --fg-host-prog ": $AUTO2STEP3B_PROG" \
     --fg-host-prog ": sleep 45" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
     }

source `dirname "$0"`/../../run_alv.sh
