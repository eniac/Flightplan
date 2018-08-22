# BMV2 Build Process

The first time that you are building the booster switch, `configure` must be provided
as a target (as below). Subsequent times, building will be faster with `configure` excluded.

By default, running `make configure` from this directory will build all available boosters.

To build only fec boosters, run:
`make configure BOOSTERS=FEC`
To build only memcached boosters, run
`make configure BOOSTERS=MEMCACHED`
