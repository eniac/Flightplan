#include "booster_primitives.hpp"
#include <bm/bm_sim/extern.h>
#include <bm/bm_sim/P4Objects.h>
#include <bm/bm_sim/logger.h>
using namespace bm;

class SenderSeqState : public ExternType {
 public:

  /** These attributes should be settable in the SenderSeqState constructor */
  BM_EXTERN_ATTRIBUTES {
    BM_EXTERN_ATTRIBUTE_ADD(seq);
  }

  /** Called on construction, after attributes have been set */
  void init() override {
    seq_ = seq.get<int>();
    BMLOG_DEBUG("Initialized SenderSeqState with seq: {}", seq_);
  }

  void nextSeq(Data &next_seq) {
    seq_++;
    next_seq.set(seq_);
  }

 private:
  // declared attributes
  Data seq{0};

  // implementation members
  int seq_;
};

BM_REGISTER_EXTERN(SenderSeqState);
BM_REGISTER_EXTERN_METHOD(SenderSeqState, nextSeq, Data &);

/** This function stops the linker from discarding this file*/
void import_seq_extern_object(SimpleSwitch *sswitch) {
    (void)sswitch; // Avoids unused warning
}
