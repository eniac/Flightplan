# Info
This example shows the Full runtime's fail-over mechanism reacting to simulated packet loss.

## What you see
A series of packets are sent from p0h0 to p1h0, and Flightplan's control program is used
to deliberately corrupt the dataplane state, to simulate failure.
fpctl's usage in this experiment is scripted -- [example](step2.sh).
As the Full runtime assesses this failure, you'll see feedback packets being
exchanged between dataplanes.
At some point the runtimes will decide to fail-over to a different dataplane,
at which point you'll see traffic following a different path.


# Code

## Running
```
sudo tests.sh
```
