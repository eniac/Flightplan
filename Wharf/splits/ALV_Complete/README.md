```
nsultana@tclust9:~/2/P4Boosters/Wharf$ sudo bash -c "source /home/nsultana/envir.sh; MODE=autotest_long splits/ALV_Complete/tests.sh"
...
nsultana@tclust9:~/2/P4Boosters/Wharf$ grep loss -R test_output/alv_k\=4/log_files/ --color=always | more
test_output/alv_k=4/log_files/p0h0_prog_20.log:10 packets transmitted, 10 received, 0% packet loss, time 9041ms
test_output/alv_k=4/log_files/p0h0_prog_25.log:10 packets transmitted, 10 received, 0% packet loss, time 9014ms
test_output/alv_k=4/log_files/p0h0_prog_19.log:10 packets transmitted, 10 received, 0% packet loss, time 9009ms
test_output/alv_k=4/log_files/p0h0_prog_21.log:10 packets transmitted, 10 received, 0% packet loss, time 9014ms
test_output/alv_k=4/log_files/p0h0_prog_22.log:10 packets transmitted, 10 received, 0% packet loss, time 9028ms
test_output/alv_k=4/log_files/p0h0_prog_23.log:10 packets transmitted, 10 received, 0% packet loss, time 9013ms
test_output/alv_k=4/log_files/p0h0_prog_24.log:10 packets transmitted, 10 received, 0% packet loss, time 9016ms
test_output/alv_k=4/log_files/p0h0_prog_18.log:10 packets transmitted, 10 received, 0% packet loss, time 9216ms
```

Experiment can be tweaked by modifying the rules for the following tables in the topology file: dropper, check_run_Complete_ingress, check_run_Complete_egress
Dropping can interfere randomly with the mcd test -- disabling dropping gives more stable results.
