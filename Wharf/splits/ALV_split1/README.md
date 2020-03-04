TOPOLOGY=splits/ALV_split1/alv_k=4.yml # derived from bmv2/topologies/alv_k=4.yml
CONTROLDATA=splits/ALV_split1/FPControlData.yml

nsultana@tclust9:Wharf$./FPControl.py $TOPOLOGY $CONTROLDATA configure_flightplan --force && ./FPControl.py $TOPOLOGY $CONTROLDATA start
nsultana@tclust9:Wharf$ # 13 pings
nsultana@tclust9:Wharf$ ./FPControl.py $TOPOLOGY $CONTROLDATA get_pip_state --switch p0e0; ./FPControl.py $TOPOLOGY $CONTROLDATA get_pip_state --switch FPoffload; ./FPControl.py $TOPOLOGY $CONTROLDATA get_pip_state --switch FPoffload2
Result: {'p0e0': [{'0': [{'flightplan_pip_syn_next': '0'}, {'flightplan_pip_seqno': '26'}, {'flightplan_pip_expecting_ack': '0'}, {'flightplan_pip_seqno_ackreq_sent': '24'}, {'flightplan_pip_nak_count': '0'}, {'flightplan_pip_nak_count_max': '5'}, {'flightplan_pip_ackreq_interval': '10'}, {'flightplan_pip_ackreq_interval_exceed_max': '10'}]}]}
Result: {'FPoffload': [{'0': [{'flightplan_pip_syn_next': '0'}, {'flightplan_pip_seqno': '25'}, {'flightplan_pip_expecting_ack': '0'}, {'flightplan_pip_seqno_ackreq_sent': '0'}, {'flightplan_pip_nak_count': '0'}, {'flightplan_pip_nak_count_max': '5'}, {'flightplan_pip_ackreq_interval': '10'}, {'flightplan_pip_ackreq_interval_exceed_max': '10'}]}]}
Result: {'FPoffload2': [{'0': [{'flightplan_pip_syn_next': '1'}, {'flightplan_pip_seqno': '0'}, {'flightplan_pip_expecting_ack': '0'}, {'flightplan_pip_seqno_ackreq_sent': '0'}, {'flightplan_pip_nak_count': '0'}, {'flightplan_pip_nak_count_max': '5'}, {'flightplan_pip_ackreq_interval': '10'}, {'flightplan_pip_ackreq_interval_exceed_max': '10'}]}]}

nsultana@tclust9:Wharf$ ./FPControl.py $TOPOLOGY $CONTROLDATA set_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_nak_count --value 6
nsultana@tclust9:Wharf$ ./FPControl.py $TOPOLOGY $CONTROLDATA set_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_seqno --value 27

nsultana@tclust9:Wharf$ # 4 pings
nsultana@tclust9:Wharf$ ./FPControl.py $TOPOLOGY $CONTROLDATA get_pip_state --switch p0e0; ./FPControl.py $TOPOLOGY $CONTROLDATA get_pip_state --switch FPoffload; ./FPControl.py $TOPOLOGY $CONTROLDATA get_pip_state --switch FPoffload2
Result: {'p0e0': [{'0': [{'flightplan_pip_syn_next': '0'}, {'flightplan_pip_seqno': '7'}, {'flightplan_pip_expecting_ack': '0'}, {'flightplan_pip_seqno_ackreq_sent': '0'}, {'flightplan_pip_nak_count': '0'}, {'flightplan_pip_nak_count_max': '5'}, {'flightplan_pip_ackreq_interval': '10'}, {'flightplan_pip_ackreq_interval_exceed_max': '10'}]}]}
Result: {'FPoffload': [{'0': [{'flightplan_pip_syn_next': '0'}, {'flightplan_pip_seqno': '27'}, {'flightplan_pip_expecting_ack': '0'}, {'flightplan_pip_seqno_ackreq_sent': '0'}, {'flightplan_pip_nak_count': '1'}, {'flightplan_pip_nak_count_max': '5'}, {'flightplan_pip_ackreq_interval': '10'}, {'flightplan_pip_ackreq_interval_exceed_max': '10'}]}]}
Result: {'FPoffload2': [{'0': [{'flightplan_pip_syn_next': '0'}, {'flightplan_pip_seqno': '6'}, {'flightplan_pip_expecting_ack': '0'}, {'flightplan_pip_seqno_ackreq_sent': '0'}, {'flightplan_pip_nak_count': '0'}, {'flightplan_pip_nak_count_max': '5'}, {'flightplan_pip_ackreq_interval': '10'}, {'flightplan_pip_ackreq_interval_exceed_max': '10'}]}]}
