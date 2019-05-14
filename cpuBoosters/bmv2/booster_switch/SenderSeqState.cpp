#include "booster_primitives.hpp"
#include <bm/bm_sim/extern.h>
#include <bm/bm_sim/P4Objects.h>
#include <bm/bm_sim/logger.h>
using namespace bm;

class SenderSeqState : public ExternType {
 public:

  /** These attributes should be settable in the SenderSeqState constructor */
  BM_EXTERN_ATTRIBUTES {
    BM_EXTERN_ATTRIBUTE_ADD(initial_seq);
  }

  /** Called on construction, after attributes have been set */
  void init() override {
    seq_ = initial_seq.get<int>();
    BMLOG_DEBUG("Constructed SenderSeqState with initial_seq: {}", seq_);
  }

  void initSeq(Data &initial_seq) {
    if (!initialised) {
        this->initial_seq.set<int>(initial_seq.get<int>());
        seq_ = initial_seq.get<int>();
        BMLOG_DEBUG("Initialized SenderSeqState with initial_seq: {}", seq_);
        initialised = true;
    }
  }

  void nextSeq(Data &next_seq) {
    const int pre_seq = seq_;
    seq_++;
    next_seq.set(seq_);
    BMLOG_DEBUG("Updated SenderSeqState seq: {} to {}", pre_seq, seq_);
  }

 private:
  // declared attributes
  Data initial_seq{0};

  // implementation members
  int seq_;
  bool initialised = false;
};

BM_REGISTER_EXTERN(SenderSeqState);
BM_REGISTER_EXTERN_METHOD(SenderSeqState, initSeq, Data &);
BM_REGISTER_EXTERN_METHOD(SenderSeqState, nextSeq, Data &);

/** This function stops the linker from discarding this file*/
void import_seq_extern_object(SimpleSwitch *sswitch) {
    (void)sswitch; // Avoids unused warning
}
