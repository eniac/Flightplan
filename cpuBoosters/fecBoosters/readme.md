# FEC Encoder booster

## Running

The each booster accepts arguments:

```
./<booster> -i input_interface [-o output_interface] [-r rules.csv]
```
Where `rules.csv` is a list of rules to pass to the fec API.

### Rules format

The input rules must be one of the following:

```shell
ENABLE [1/0]             # Enables with 1, disables with 0. With no args prints current state
CLASS <id> <h> <k> <t>   # Defines a new traffic class
DELCLASS <id>            # Deletes the traffic class with the provided ID
DEFAULT <id>             # Sets the default class for unmatched traffic
SET <port> <tcp> <class> # Sets the port and protocol (tcp = 1, udp = 0) to match the class ID.
                         # NOTE: Class ID must have been previously defined.
DEL <port> <tcp> <class> # Removes the rule associated associated with the given parameters
QUERY <port> <tcp>       # Returns the class assigned to the given port and IP
LIST                     # Prints the current class & rule list to stderr
```

An example rule file might look like:
```
CLASS 0 5 2 1   # Sets traffic of class 0 to have k = 5, h = 2, t = 1
CLASS 1 10 2 1  # Sets traffic of class 10 to have k = 10, h = 2, t = 1
SET 8888 0 0    # UDP traffic over port 8888 is marked as class 0
SET 8181 1 1    # TCP traffic over port 8181 is marked as class 1
DEFAULT 1       # Any other traffic is also marked as class 1
ENABLE 1        # Tagging must be enabled!
```
NOTE: Comments do not work in the syntax of the rule file and are added here
for descriptive purposes only

Two sample rule files are provided for convenience:
* `tag_all.txt`
  * Tags all packets as class 1 with  k=10, h=2, t=1
* `tcp_udp_12340-3_rules.txt`
  * Tags tcp and udp packets arriving over ports 12340-12343 with
various values of k and h
* `tag_cls_0.txt`
  * Tags all packets as class 0 with k=5, h=1, and no timeout

## Running tests

Two scripts exist to test the functionality of the cpu boosters:

* `vethTestE2E.sh`: End-to-end test of encode, forward w/ drop, decode
* `vethTestDecode.sh`: Tests decode-only, using a pre-encoded file (potentially from hardware)

At the end of both tests, the scripts will output a (hopefully blank) diff between
the decoded output and un-encoded input, as well as any explicit errors encountered
while running the test.

Test output (including stderr, tcpdump, and diff)  is placed in `test_output/<input>/`

### End-to-end test

```shell
$ sudo  vethTestE2E.sh input.pcap rules_table.txt num_reps delay
```

To be thorough, each test should be run with reps=`2`, delay=`3`.

If `delay < 3`, tests should fail due to timeouts not being met.

This test should be run with the following sets of parameters:

* input: `../pcaps/test.pcap` rules: `tag_all.txt`
  * Simple test with a few packets
* input: `../pcaps/tofinoProcessed_iperfClient2Server.pcap` rules:`tag_all.txt`
  * Many more packets than the last test.
* input: `../pcaps/tcp_udp_12340-3.pcap` rules: `tcp_udp_12340-3_rules.txt`
  * Tests that varying k and h based on port and protocol works
  * To fully check this test, verify in `test_output/tcp_udp_12340-3/encoder.txt`
    that various values of k and h are used

### Decode test

```shell
$ sudo vethTestDecode.sh encoded.pcap rules_table.txt input.pcap
```

This test should be run with:

* encoded: `../pcaps/encoded_inputs.pcap` rules: `tag_cls_0.txt` input: `../pcaps/decoded_inputs.pcap`
  * NOTE: At the moment, this test is failing with a difference of 1 in the number of output
    lines. This is due to a bug in the encoded file in which the first encoded packet
    has an index of 0. If the script shows only a difference of one line, it can be ignored
    for now.


