# Build

## Generate C-Simulation and RTL Simulation Testbenches
Run `make ($BOOSTER_NAME)P4`

## Generate Bitstreams for Boosters
Run `make ($BOOSTER_NAME)($NUM_OF_PORTS)PortsVivado`

## Generate SDx Project for Configuring Board
Run `make ($BOOSTER_NAME)($NUM_OF_PORTS)PortsVivado`
Where `$NUM_OF_PORTS` should be 1, 2 or 4.

# List of Booster Name
RSEEncoder
RSEDecoder
Memcached
Compressor
Decompressor
