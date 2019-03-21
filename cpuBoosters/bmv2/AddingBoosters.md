# Adding Boosters to the Behavioral Model
This document outlines the steps necesasry to add a new booster to the
behavioral model simulation of P4.

The document assumes that the booster has already been written to function in a different
environment (such as libpcap or on FPGA), and will discuss the steps necessary
in porting the booster to the bmv2 environment.

## Booster modifications
For consistency, booster code should live in `P4Boosters/cpuBoosters/XXX`
(the folder should share this directory's parent).

The following modifications must be made to the booster code itself

### Separation of business logic
If the booster was originally written for use with libpcap, it's likely that the implementation
consists of only a single file, which defines both the packet processing behavior and the
`main()` declaration specifying pcap behavior.

This file must be separated into two pieces -- one to handle the business logic of forwarding
packets, and another (if keeping pcap behavior is desired) which sets up the pcap monitor.

### Generating Packets

Boosters may have to generate new packets, rather than simply modifying existing packets,
in order to function correctly.

To enable support for this, the first step is to modify the existing booster code to
be able to use an arbitrary function to packet generation. This typically
means that the function must take in an additional argument, which is the function handle
specifying forwarding behavior.

In the case of Header Compression, the following definition was appended to `compressor.h`:

```c++
using forward_fn = std::function<void(const u_char *payload, size_t size)>;
```

And then the packet processing code was changed to accept a `forward_fn`:

```c++
void decompress(const u_char*packet, uint32_t pktLen, forward_fn forward);
void compress(const u_char*packet, uint32_t pktLen, forward_fn forward);
```

pcap functionality was maintained by wrapping `pcap_inject()` in a lambda which matches
the `forward_fn` signature:

```c++
auto forward_fn = [](const u_char *payload, size_t size) {
    pcap_inject(pcap, payload, size);
};
compress(packet, pkthdr->len, forward_fn);
```

### Makefile modifications
A new target must be added to the booster makefile so that modifications will
be copied to the `cpuBoosters/bmv2/` directory. For consistency, this target should
be named `copy_files`, and should have the following format:

```make
BOOSTER_SWITCH_DIR=../bmv2/booster_switch/
BOOSTER_SWITCH_XXX_DIR=$(BOOSTER_SWITCH_DIR)XXXBoosters/

copy_files:
	rsync -av ./* $(BOOSTER_SWITCH_XXX_DIR)
```

Where XXX is replaced with the name of the booster being ported.


## bmv2 modifications
All modifications to bmv2 are done from files in this repository, rather than
making the modifications directly in the `behavioral_model` repository.

### Build modifications
The bmv2 build process must be modified to recognize the new boosters.
This requires modification in two locations:

#### bmv2/Makefile

First, add the booster to the list of default boosters in the makefile:
```Make
BOOSTERS?=MEMCACHED FEC COMPRESSION XXX
```

Then, add the folder into which the boosters are copied by the booster target
`copy_files`, and the appropriate config flag, if the booster is specified to be built:

```Make
ifneq ($(findstring XXX,$(BOOSTERS)),)
BOOSTER_DEPS+=booster_switch/XXXBoosters
CONFIG_FLAGS+=XXX_BOOSTER=true
$(info Attempting build of XXX boosters)
endif
```

Finally, add the target that will automatically copy the files into this directory:

```Make
booster_switch/XXXBoosters:
    cd ../XXX && make copy_files
```

### configure.ac

The bmv2 top-level configuration file must also be modified to enable compilation of
the new booster. To do so, add one additional line to `patches/configure.ac.patch`:

```
+AM_CONDITIONAL([BUILD_XXX_BOOSTER], [test x$XXX_BOOSTER != x ] )
```
** NB: Be sure to modify the number of lines affected at the top of the file as well.
e.g. `270,11 -> 270,12` **


## Booster Addition

Adding the booster to be recognized as an extern will consist of:
creating booster primitive wrapper, adding the wrapper to the build, and importing
the new booster primitive.

### Creating the wrapper

This example assumes that the booster accepts one argument, which signals P4
whether or not it should drop the created packet.


```c++
// FILE: XXX_booster_primimtives.cpp
#include "booster_primitives.hpp" // Necessary for BoosterExtern
#include "simple_switch.h"        // Necessary for registration
#include "XXX.h"           // Whatever custom header defines your booster

#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/data.h>
#include <bm/bm_sim/packet.h>

using bm::Data;
using bm::Packet;
using bm::Header;

// The <Data &> below defines the type and number  of arguments your booster will accept
class boost_XXX : public boosters::BoosterExtern<Data &> {
    using BoosterExtern::BoosterExtern;

    void operator ()(Data &forward_d) {

        // Packets created by this booster with `generate_packet` are passed to the
        // booster again. They must be treated differently.
        if (is_generated()) {
            forward_d.set(true);
            return;
        }

        Packet  &packet = this->get_packet();
        int ingress_port = packet.get_ingress_port();

        // Must save packet state so it can be restored after deparsing
        const Packet::buffer_state_t packet_in_state = packet.save_buffer_state();

        // Deparsing the packet makes the headers readable in packet.data()
        auto deparser = get_p4objects()->get_deparser("deparser");
        deparser->deparse(&packet);

        char *buff = packet.data();
        size_t buff_size = packet.get_data_size();

        // This lambda is called by the booster if it decides to forward
        auto forwarder = [&](const u_char *payload, size_t len) {
            BMLOG_DEBUG("Generating new packet");
            generate_packet((const char *)payload, len, ingress_port);
        };

        // Call your booster-specific code here:
        XXX(buff, buff_size, forwarder);

        // Necessary for continued processing
        packet.restore_buffer_state(packet_in_state);

        // Set whether to keep the processed packet or not
        forward_d.set(True);
    }
};

// This function will be called from the switch object to
// register the booster extern with P4
int import_XXX_booster_primitives(SimpleSwitch *sswitch) {
    REGISTER_BOOSTER_EXTERN(boost_XXX, sswitch);
    return 0;
}

```
An additional file, `XXX_booster_primitives.h` should be added which
simply declares the `import_XXX_booster_primitives()` function.

### Adding wrapper to the `booster_switch` build
The `booster_switch/Makefile.am` must be told to build the newly added
`XXX_booster_primitives.cpp` files, and any additional files required by
the booster.

Add the following lines to `booster_switch/Makefile.am`:

```Make
if BUILD_XXX_BOOSTER
BOOSTER_INCLUDES+=\
	-I./XXXBoosters
BOOSTER_sources+=XXX_booster_primitives.cpp XXXBoosters/<necessary_file>.cpp
BOOSTER_DEFINES+=-DXXX_BOOSTER # Add precompiler definition to enable booster operation
endif
```

### Importing booster externs
Finally, in `booster_switch/booster_primitives.cpp`, import the `XXX_booster_primitives.h`
file, and then add the relevant `import_XXX_booster_primitives()` call to
`import_booster_externs()`, surrounded by the relevant ifdef:

```c++
#ifdef XXX_BOOSTER
    import_XXX_booster_primitives(sswitch);
#endif
```
