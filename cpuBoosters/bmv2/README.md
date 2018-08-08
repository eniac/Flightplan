# BMV2 Build Process

By default, running `make` from this directory will build all available boosters.

To build only fec boosters, run:
`make BOOSTERS=FEC`
To build only memcached boosters, run
`make BOOSTERS=MEMCACHED`

(**Note**: `make clean` might be necessary if bmv2 repo has already been configured to
 build a different set of boosters)


