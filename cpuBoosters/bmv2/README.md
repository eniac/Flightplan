# Contents

This directory contains the `booster_switch`, which is added as a new target
to the p4 `behavioral_model`, and additional patches which are to be
added core `behavioral_model` codebase.

Patches do not have to be applied manually -- they are checked for correctness
and applied upon running `make`.


## Build Requirements

Before building, the environment variable `BMV2_REPO` must be set to reference
the location of the cloned `behavioral_model` repository.

One should build the behavioral model first, then run `make configure` here
to apply the appropriate patches and rebuild.

The patches into the behavioral model have been tested with:
* commit `c67f85d45feea5c31312c9a1e8a7063a976a1469` of the `behavioral_model` repo
* commit `730986bd4dce83a121159d06beb08ffa961afdc7` of the `p4c` repo

though it will likely be applicable to newer revisions as well.

If building the Memcached booster, `Vivado_HLS` is also required.
Set the environment variable `XILINX_DIR` to be the parent directory
of the `VIVADO_HLS` directory to properly build the Memcached booster.


## Build Process

The first time that you are building the booster switch, `configure` must be provided
as a target (as below). Subsequent times, building will be faster with `configure` excluded.

By default, running `make configure` from this directory will build all available boosters.

To build only FEC boosters, run:
`make configure BOOSTERS=FEC`
To build only the Memcached booster, run
`make configure BOOSTERS=MEMCACHED`
To build only the Header Compression booster, run:
`make configure BOOSTERS=COMPRESSION`
To build multiple boosters (i.e. FEC and compression), run:
`make configure BOOSTERS="FEC COMPRESSION"`

After running `make configure`, run `make` to finish building the `booster_switch`.

## Testing

The patches and new target can be tested using the `complete_fec_e2e` and
`complete_mcd_e2e` scripts, described in [Wharf/README.md](../../Wharf/README.md)
