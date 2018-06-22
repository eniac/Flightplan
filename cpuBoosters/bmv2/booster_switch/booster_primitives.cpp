#include <bm/bm_sim/actions.h>
#include <bm/bm_sim/calculations.h>
#include <bm/bm_sim/core/primitives.h>
#include <bm/bm_sim/counters.h>
#include <bm/bm_sim/meters.h>
#include <bm/bm_sim/packet.h>
#include <bm/bm_sim/phv.h>

#include <iostream>
#include <fstream>

template <typename... Args>
using ActionPrimitive = bm::ActionPrimitive<Args...>;

using bm::Data;
using bm::Field;
using bm::Header;
using bm::MeterArray;
using bm::CounterArray;
using bm::RegisterArray;
using bm::NamedCalculation;
using bm::HeaderStack;

class boost_fn : public ActionPrimitive<const Field &> {
    void operator ()(const Field &d) {
        (void)d;
        std::ofstream outfile ("test.txt", std::ios_base::app);
        outfile << " data " << &get_packet().data()[16+16+8] << " Ethertype: " << std::hex << d << std::endl;
        outfile.close();
        //get_field("fec.traffic_class").set(3);
        ///get_field("eth.type").set((uint16_t)0x0800);
    }
};

REGISTER_PRIMITIVE(boost_fn);

// dummy function, which ensures that this unit is not discarded by the linker
// it is being called by the constructor of SimpleSwitch
// the previous alternative was to have all the primitives in a header file (the
// primitives could also be placed in simple_switch.cpp directly), but I need
// this dummy function if I want to keep the primitives in their own file
int import_booster_primitives() {
  return 0;
}
