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

  void initSeq(const Data &initial_seq) {
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
BM_REGISTER_EXTERN_METHOD(SenderSeqState, initSeq, const Data &);
BM_REGISTER_EXTERN_METHOD(SenderSeqState, nextSeq, Data &);

/** This function stops the linker from discarding this file*/
void import_seq_extern_object(SimpleSwitch *sswitch) {
    (void)sswitch; // Avoids unused warning
}

class ReceiverNakState : public ExternType {
 public:

  /** These attributes should be settable in the SenderSeqState constructor */
  BM_EXTERN_ATTRIBUTES {
    BM_EXTERN_ATTRIBUTE_ADD(initial_seq);
  }

  /** Called on construction, after attributes have been set */
  void init() override {
    seq_ = initial_seq.get<int>();
    BMLOG_DEBUG("Constructed ReceiverNakState with initial_seq: {}", seq_);
  }

  void initSeq(const Data &initial_seq) {
    BMLOG_DEBUG("ReceiverNakState initSeq..."); // FIXME
    if (!initialised) {
        this->initial_seq.set<int>(initial_seq.get<int>());
        seq_ = initial_seq.get<int>();
        BMLOG_DEBUG("Initialized ReceiverNakState with initial_seq: {}", seq_);
        initialised = true;
    }
  }

  void nextSeq(const Data &next_seq, Data &ok) {
    BMLOG_DEBUG("ReceiverNakState nextSeq..."); // FIXME
    const int pre_seq = seq_;
    if (next_seq.get<int>() == seq_ + 1) {
        seq_++;
        ok.set<bool>(true);
    } else {
        ok.set<bool>(false);
    }
    BMLOG_DEBUG("ReceiverNakState nextSeq({} -> {}, {})", next_seq.get<int>(), seq_, ok.get<bool>());
  }

  void relink(Data &ok) {
    // TODO
    ok.set<bool>(true);
    BMLOG_DEBUG("ReceiverNakState relink");
  }

 private:
  // declared attributes
  Data initial_seq{0};

  // implementation members
  int seq_;
  bool initialised = false;
};

BM_REGISTER_EXTERN(ReceiverNakState);
BM_REGISTER_EXTERN_METHOD(ReceiverNakState, initSeq, const Data &);
BM_REGISTER_EXTERN_METHOD(ReceiverNakState, nextSeq, const Data &, Data &);
BM_REGISTER_EXTERN_METHOD(ReceiverNakState, relink, Data &);

/** This function stops the linker from discarding this file*/
void import_nak_extern_object(SimpleSwitch *sswitch) {
    (void)sswitch; // Avoids unused warning
}
