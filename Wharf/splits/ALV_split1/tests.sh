#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# FIXME various hardcoded paths

TOPOLOGY=splits/ALV_split1/alv_k=4.yml
MODES=(demo1 autotest1 autotest2)

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

source `dirname "$0"`/../../run_alv.sh
