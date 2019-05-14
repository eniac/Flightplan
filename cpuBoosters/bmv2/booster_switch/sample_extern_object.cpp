#include "booster_primitives.hpp"
#include <bm/bm_sim/extern.h>
#include <bm/bm_sim/P4Objects.h>
#include <bm/bm_sim/logger.h>
using namespace bm;

class SampleExtern : public ExternType {
 public:

  /** These attributes should be settable in the SampleExtern constructor */
  BM_EXTERN_ATTRIBUTES {
    BM_EXTERN_ATTRIBUTE_ADD(sample_state_1);
    BM_EXTERN_ATTRIBUTE_ADD(sample_state_2);
  }

  /** Called on construction, after attributes have been set */
  void init() override {
    sample_state_1_ = sample_state_1.get<int>();
    sample_state_2_ = sample_state_2.get<int>();
    BMLOG_DEBUG("Initialized SampleExtern with values 1: {} & 2: {}",
                sample_state_1_, sample_state_2_);
  }

  void increment_both_by_1() {
    sample_state_1_ += 1;
    sample_state_2_ += 1;
    BMLOG_DEBUG("SampleExtern state_1 : {}", sample_state_1_);
    BMLOG_DEBUG("SampleExtern state_2 : {}", sample_state_2_);
  }

  void increment_1(const Data &d) {
    sample_state_1_ += d.get<int>();
    BMLOG_DEBUG("SampleExtern state_1 : {}", sample_state_1_);
  }

  void increment_2(const Data &d) {
    sample_state_2_ += d.get<int>();
    BMLOG_DEBUG("SampleExtern state_2 : {}", sample_state_2_);
  }

  void is_1_more_than(const Data &d, Data &out) {
    int value = d.get<int>();
    if (sample_state_1_ > value) {
        BMLOG_DEBUG("SampleExtern Value {} > {}", value, sample_state_1_);
        out.set(1);
    } else {
        BMLOG_DEBUG("SampleExtern Value {} <= {}", value, sample_state_1_);
        out.set(0);
    }
  }

 private:
  // declared attributes
  Data sample_state_1{0};
  Data sample_state_2{0};

  // implementation members
  int sample_state_1_;
  int sample_state_2_;
};

BM_REGISTER_EXTERN(SampleExtern);
BM_REGISTER_EXTERN_METHOD(SampleExtern, increment_1, const Data &);
BM_REGISTER_EXTERN_METHOD(SampleExtern, increment_2, const Data &);
BM_REGISTER_EXTERN_METHOD(SampleExtern, is_1_more_than, const Data &, Data &);
BM_REGISTER_EXTERN_METHOD(SampleExtern, increment_both_by_1);

/** This function stops the linker from discarding this file*/
void import_sample_extern_object(SimpleSwitch *sswitch) {
    (void)sswitch; // Avoids unused warning
}
