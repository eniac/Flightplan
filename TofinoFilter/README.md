### Simple L2 booster for tofino ###

#### Overview ####

P4 program and control script for layer 2 boosting on the tofino. Currently wired with 40 Gbit/s links.

Topology:

![Tofino Filter Topology](./images/boosterconfig.png)


#### Build ####

```
. ./set_sde.bash
cd $SDE
./p4_build.sh $PROGPATH/p4src/$PROGNAME.p4 --with-tofinobm
# ./p4_build.sh $PROGPATH/p4src/$PROGNAME.p4 --with-tofino
```

#### Test ####

*(only if running on simulator)*
```
sudo $SDE_INSTALL/bin/veth_setup.sh
sudo $SDE_INSTALL/bin/dma_setup.sh
```

```
cd $SDE
./run_tofino_model.sh -p $PROGNAME
```

*(on simulator or switch)*
```
cd $SDE
./run_switchd.sh -c  $SDE_INSTALL/share/p4/targets/$PROGNAME.conf
```

```
cd $PROGPATH
./runControlScript.sh
```

#### start booster (on booster host: qubit0, port = ens27f1)
#### send/receive traffic (on traffic host: tg-1, ports = enp5s0f0, enp5s0f1)


