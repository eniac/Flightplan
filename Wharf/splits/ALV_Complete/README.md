# About this example
This example---called [Crosspod in the Flightplan paper](https://flightplan.cis.upenn.edu/flightplan.pdf#section.2)---features a program that invokes 3 types of (in-network) boosters:
* link-layer Forward Error Correction (**FEC**)
* Memcached Cache (**MCD**)
* Header Compression (**HC**)
These boosters are described further in the Flightplan paper, and the FEC implementation is detailed in our [NetCompute'18 paper](https://www.seas.upenn.edu/~nsultana/files/netcompute.pdf).

## What you see
Various experiments are run to test the behaviour of these boosters.
* **FEC**: we measure the number of packets that reach the destination after crossing a lossy link. Using FEC we are able to get more data packets across.
* **MCD**: we measure the Memcached queries to the server that are avoided when the in-network cache can respond to them. Using the in-network cache, fewer GET requests reach the server and thus reduce pressure on it.
* **HC**: we measure the number of bytes sent across across a network link when the compression booster is active compared to when it isn't.


# Code
The [scripted experiments](tests.sh) contain all setup and invocation details.

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
Also if that test keeps failing mysteriously then check the `TARGET_LOG` variable in the tests script, it might be pointing to the wrong file.
