### FEC Encoder booster ###

example usage: `sudo ./vethTestBooster.sh ../pcaps/tofinoProcessed_iperfClient2Server.pcap`

for end-to-end test: `sudo ./vethTestE2EBooster.sh test.pcap`

for end-to-end test with larger input: `sudo ./vethTestE2EBooster.sh ../pcaps/tofinoProcessed_iperfClient2Server.pcap`

End-to-end test will send in input file, pause for 5 seconds (which is longer than the
encode/decode timeouts), then send the input again.

This ensures that normal operation, timeout, and recovery from timeout all work properly.

At the end of the end-to-end test, the number of lines in the input and output will be shown
to verify correct operation. These values should match.
