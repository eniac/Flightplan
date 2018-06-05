### FEC Encoder booster ###

example usage: `sudo ./vethTestBooster.sh ../pcaps/tofinoProcessed_iperfClient2Server.pcap`

* for end-to-end test:
`sudo ./vethTestE2EBooster.sh test.pcap`

* for end-to-end test with larger input:
`sudo ./vethTestE2EBooster.sh ../pcaps/tofinoProcessed_iperfClient2Server.pcap`

End-to-end test will send in input file, pause for 5 seconds (which is longer than the
encode/decode timeouts), then send the input again. The encode/decode timeout can be modified
in fecBooster.h through the variables `WHARF_DECODE_TIMEOUT` and `WHARF_ENCODE_TIMEOUT`.

This ensures that normal operation, timeout, and recovery from timeout all work properly.

At the end of the end-to-end test, the number of lines in the input and output will be shown
to verify correct operation. These values should match.


* for decoding-only test: `sudo ./vethTestDecodeBooster.sh <encoded_input.pcap> <input.pcap>`

Decoding-only test accepts an input that has already been encoded, and the unencoded version of that input.
It then strips the fec header from the input and tests if it matches the output.

* for dropping + decoding test: `sudo ./vethTestForwardDecodeBooster.sh <encoded_input.pcap> <input.pcap>`

Dropping + decoding accepts the same arguments as decode-only, but drops some portion of packets
(configurable in `forwardingNonbooster.c`), and ensures the decoder can reconstruct them.

Sample arguments are:

`sudo ./vethTestDecodeBooster.sh ../pcaps/encoded_inputs.pcap ../pcaps/decoded_inputs.pcap`

* for checking packet tagging:
`sudo bash vethTestTableBooster.sh ../pcaps/udp_varied_ports.pcap tcp_udp_test_rules.csv` and
`sudo bash vethTestTableBooster.sh ../pcaps/tcp_varied_ports.pcap tcp_udp_test_rules.csv`

Should check for lines `Untagged packet should have had class _` or `Traffic classes do not match`.

NOTE: Will only perform check if CHECK_TABLE_ON_DECODE is defined in fecDeodeBooster.c

