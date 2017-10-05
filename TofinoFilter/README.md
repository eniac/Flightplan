### Simple L2 booster for tofino ###

#### Overview ####

P4 program and control script for layer 2 boosting on the tofino. Currently wired with 40 Gbit/s links.

Topology:

![GitHub Logo](/images/booster.png)


#### Prerequisites ####
- build and install the barefoot sde:
	https://support.barefootnetworks.com/hc/en-us/articles/115002796007-Building-SDE-in-two-easy-steps
- download the following convenience scripts and put them in the main sde dir: 
	- set_sde.bash (https://support.barefootnetworks.com/hc/en-us/article_attachments/115012334207/set_sde.bash)
	- p4_build.sh (https://support.barefootnetworks.com/hc/en-us/article_attachments/115001498013/p4_build.sh)
instructions assume barefoot sde is in: ~/bf_sdk/bf-sde-5.0.1.21
- 

#### Path Setup ####

_run commands from main program directory, i.e. p4code/barefoot/boostFilter_

```
# set path for P4 code dir. 
PROGPATH=`pwd`
# set path for sde dirs.
cd ~/bf_sdk/bf-sde-5.0.1.21
. ./set_sde.bash
export PATH=$SDE_INSTALL/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$SDE_INSTALL/lib:$LD_LIBRARY_PATH
```
#### Building the Example ####
```
cd $SDE
./p4_build.sh $PROGPATH/p4src/boostFilter.p4 --with-tofino
```
this script:
	1. builds to $SDE/build/p4-build
	2. installs configuration files, binaries, etc, in subdirs of $SDE_INSTALL

#### Testing the Example ####

#### start switch control agent.
cd $SDE
./run_switchd.sh -p  boostFilter

#### insert forwarding rules.
cd $PROGPATH
./runControlScript.sh


#### start booster (on booster host: qubit0, port = ens27f1)
#### send/receive traffic (on traffic host: tg-1, ports = enp5s0f0, enp5s0f1)
