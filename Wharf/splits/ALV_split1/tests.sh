#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# FIXME various hardcoded paths
# FIXME poor naming choices for tests

TOPOLOGY=$WHARF_REPO/splits/ALV_split1/alv_k=4.yml
MODES=(demo1 autotest1 autotest2 autotest2B autotest_long autotest3B)

if [ -z "${MODE}" ]
then
  MODE=autotest1
  echo "Using default MODE from $0"
fi

function demo1 {
  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog "p0h0: ping -c 1 192.0.0.2" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/start.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.0.0.2" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest1 {

  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/start.sh" \
     --fg-host-prog "p0h0: ping -c 13 192.0.1.2" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/step1.sh" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/step2.sh" \
     --fg-host-prog "p0h0: ping -c 4 192.0.1.2" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/step3.sh" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest2 {
  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
          --pcap-dump $PCAP_DUMPS \
          --log $LOG_DUMPS \
          --verbose \
          --showExitStatus \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/start.sh" \
     --fg-host-prog "p0h0: ping -c 13 192.0.1.2" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/autotest2_step1.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.0.1.2" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/autotest2_step2.sh" \
     --fg-host-prog "p0h0: ping -c 12 192.0.1.2" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/autotest2_step3.sh" \
          2> $LOG_DUMPS/flightplan_mininet_log.err

  # Creating graph log file
  #log file for first supporting device
  GRAPH_LOG1=$LOG_DUMPS/FPoffload_graph.txt
  #log file for second supporting device
  GRAPH_LOG2=$LOG_DUMPS/FPoffload2_graph.txt

  # Creating empty temp file
  TEMP=$LOG_DUMPS/temp.txt

  # Take the tcp dump to temp file
  tcpdump -e -r ${PCAP_DUMPS}/p0e0_to_FPoffload.pcap | grep length > ${TEMP}

  # First packet time is a reference time to calculate the elapsed time of all the packets
  time=$(head -n 1 ${TEMP})
  readarray -d " " -t time_stream <<< ${time}

  awk -v BASE="${time_stream[0]}" '{ 
    if(/length/){
    split(BASE, base_time_array, /[:.]/)
    this_time=$1
    this_line=$0

        # split time in hr, mm, sec, milliseconds
		split(this_time, time_array, /[:.]/) 
        # convert time to microseconds
		elapsed_time=(time_array[1] - base_time_array[1])*60*60*1000*1000 + (time_array[2] - base_time_array[2])*60*1000*1000 + (time_array[3] - base_time_array[3])*1000*1000 + time_array[4] - base_time_array[4]
        printf "%s ", elapsed_time
    
        n=split(this_line, full_array, /[ ]/)
        idx=1
        for (i=1; i<=n+0; i++){
                if(full_array[i]=="length"){
                        idx=i+1
                        break
                }
        }
        len=len+full_array[idx+0]
        printf "%d\n", len+0
    }
  }' ${TEMP} > ${GRAPH_LOG1}

  > ${TEMP}

  # Take the tcp dump to temp file
  tcpdump -e -xx -r ${PCAP_DUMPS}/p0e0_to_FPoffload2.pcap | grep length > ${TEMP}

  # The second device takes over in the same test, 
  # So reference time for its packets is still the first packet time of the test.
  # and NOT the time of first packet through new device
  awk -v BASE="${time_stream[0]}" '{ 
    if(/length/){
    split(BASE, base_time_array, /[:.]/)
    this_time=$1
    this_line=$0

        split(this_time, time_array, /[:.]/) 
        elapsed_time=(time_array[1] - base_time_array[1])*60*60*1000*1000 + (time_array[2] - base_time_array[2])*60*1000*1000 + (time_array[3] - base_time_array[3])*1000*1000 + time_array[4] - base_time_array[4]
        printf "%s ", elapsed_time
    
    # find out "length" keyword. Next element to this position is actual length
		n=split(this_line, full_array, /[ ]/)
        idx=1
        for (i=1; i<=n+0; i++){
                if(full_array[i]=="length"){
                        idx=i+1
                        break
                }
        }
        len=len+full_array[idx+0]
        printf "%d\n", len+0
    }

  }' ${TEMP} > ${GRAPH_LOG2}
  rm ${TEMP}
}

function autotest2B {
  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
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
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/start2.sh" \
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
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/end.sh" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest_long {
  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
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
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/start3.sh" \
     --fg-host-prog ": sleep 1" \
     --fg-host-prog "p0h0: iperf3 -t 600 -O 1 -c 192.3.1.3 &" \
     --fg-host-prog "p1h0: iperf3 -t 600 -O 1 -c 192.2.0.2 &" \
     --fg-host-prog ": sleep 630" \
     --fg-host-prog "p0h0: ifconfig" \
     --fg-host-prog "p3h3: ifconfig" \
     --fg-host-prog "p1h0: ifconfig" \
     --fg-host-prog "p2h0: ifconfig" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/end.sh" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
}

function autotest3B {
  sudo -E python $WHARF_REPO/bmv2/start_flightplan_mininet.py ${TOPOLOGY} \
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
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/start3.sh" \
     --fg-host-prog ": sleep 1" \
     --fg-host-prog "p0h0: iperf3 -t 60 -O 1 -b 1K -c 192.3.1.3 &" \
     --fg-host-prog ": sleep 5" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/autotest2_step1B.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.3.1.3" \
     --fg-host-prog ": sleep 5" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/autotest2_step2B.sh" \
     --fg-host-prog "p0h0: ping -c 1 192.3.1.3" \
     --fg-host-prog ": sleep 10" \
     --fg-host-prog ": $WHARF_REPO/splits/ALV_split1/autotest2_step3B.sh" \
     --fg-host-prog ": sleep 45" \
          2> $LOG_DUMPS/flightplan_mininet_log.err
     }

source `dirname "$0"`/../../run_alv.sh
