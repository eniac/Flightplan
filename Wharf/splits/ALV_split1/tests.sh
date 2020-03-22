#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# FIXME various hardcoded paths
# FIXME poor naming choices for tests

TOPOLOGY=splits/ALV_split1/alv_k=4.yml
MODES=(demo1 autotest1 autotest2 autotest2B autotest_long autotest3B)

if [ -z "${MODE}" ]
then
  MODE=autotest1
  echo "Using default MODE from $0"
fi

function demo1 {
  sudo -E python bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog "p0h0: ping -c 1 192.0.0.2" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/start.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.0.0.2" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest1 {
  sudo -E python bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/start.sh" \
     --fg-host-prog "p0h0: ping -c 13 192.0.1.2" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/step1.sh" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/step2.sh" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/step3.sh" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest2 {
  sudo -E python bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/start.sh" \
     --fg-host-prog "p0h0: ping -c 13 192.0.1.2" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/autotest2_step1.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/autotest2_step2.sh" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/autotest2_step3.sh" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest2B {
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
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/start2.sh" \
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
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/end.sh" \
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
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/start3.sh" \
     --fg-host-prog ": sleep 1" \
     --fg-host-prog "p0h0: iperf3 -t 600 -O 1 -c 192.3.1.3 &" \
     --fg-host-prog "p1h0: iperf3 -t 600 -O 1 -c 192.2.0.2 &" \
     --fg-host-prog ": sleep 630" \
     --fg-host-prog "p0h0: ifconfig" \
     --fg-host-prog "p3h3: ifconfig" \
     --fg-host-prog "p1h0: ifconfig" \
     --fg-host-prog "p2h0: ifconfig" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/end.sh" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest3B {
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
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/start3.sh" \
     --fg-host-prog ": sleep 1" \
     --fg-host-prog "p0h0: iperf3 -t 60 -O 1 -b 1K -c 192.3.1.3 &" \
     --fg-host-prog ": sleep 5" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/autotest2_step1B.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.3.1.3" \
     --fg-host-prog ": sleep 5" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/autotest2_step2B.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.3.1.3" \
     --fg-host-prog ": sleep 10" \
     --fg-host-prog ": /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/autotest2_step3B.sh" \
     --fg-host-prog ": sleep 45" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
     }

source `dirname "$0"`/../../run_alv.sh
