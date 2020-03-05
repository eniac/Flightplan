/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/
#ifndef FLIGHTPLAN_HEADER_P4_
#define FLIGHTPLAN_HEADER_P4_

// Merge comment: next 2 lines were removed in adjustment when getting CheckedFragment.p4 to work again,
//                might want to review this in the future. Eventually this comment might be removed if it's deemed unimportant.
//#undef ACKing
//#undef NAKing

#define FLIGHTPLAN_VERSION_SIZE 4 /*FIXME fudge*/
#define ETHERTYPE_FLIGHTPLAN 0x2222 /*FIXME fudge*/
#define SEGMENT_DESC_SIZE 4 /*FIXME fudge*/
#define BYTE 8
#define QUAD 32
#define MAX_DATAPLANE_CLIQUE_SIZE 64 /*FIXME fudge*/
#define SEQ_WIDTH 32 /*FIXME fudge*/

#define STATE 8
#define InvalidCodeFlow 0x01
#define NoOffloadPort 0x02
#define FPSyn 0x04
#define FPAck 0x08
#define FPNak 0x10
#define FPRelink 0x20
#define FPResponse 0x40

// Flightplan header scheme
header flightplan_h {
  // Includes Ethernet header to simplify parsing, and handling by black-box external functions that aren't aware of the Flightplan header.
  bit<48> dst;
  bit<48> src;
  bit<16> type;

//  bit<FLIGHTPLAN_VERSION_SIZE> version; // This could be spared.
//  bit<16> encapsulated_ethertype; -- This can be removed if we fully encapsulate the Ethernet frame including the original Ethernet header.
  bit<SEGMENT_DESC_SIZE> from_segment;
  bit<SEGMENT_DESC_SIZE> to_segment;
//  bit<4> pad;

  bit<STATE> state;
  bit<BYTE> byte1;
  bit<BYTE> byte2;
  bit<BYTE> byte3;
  bit<BYTE> byte4;
  //bit<BYTE> byte5;
  //bit<BYTE> byte6;
  //bit<BYTE> byte7;
  //bit<BYTE> byte8;
  bit<QUAD> quad1;
  bit<QUAD> quad2;
  bit<QUAD> quad3;
  bit<SEQ_WIDTH> seqno;
}
header flightplanReceive1_h {
  // FIXME replace with fields for actual values that need to be sent.
  bit<BYTE> byte1;
  bit<BYTE> byte2;
  bit<BYTE> byte3;
  bit<BYTE> byte4;
  bit<BYTE> byte5;
  bit<BYTE> byte6;
  bit<BYTE> byte7;
  bit<BYTE> byte8;
#if defined(ACKing) || defined(NAKing)
  bit<SEQ_WIDTH> seqno;
#endif
#if defined(ACKing)
  bit<1> ack;
#endif // defined(ACKing)
#if defined(NAKing)
  bit<1> nak;
#endif // defined(NAKing)
#if defined(ACKing) || defined(NAKing)
#if defined(ACKing) && defined(NAKing)
  bit<6> k_pad;
#else
  bit<7> k_pad;
#endif // defined(ACKing) && defined(NAKing)
#endif // defined(ACKing) || defined(NAKing)
}

#if defined(ACKing) || defined(NAKing)
extern SenderSeqState {
  SenderSeqState();
  void initSeq(bit<SEQ_WIDTH> init_seq);
  void nextSeq(out bit<SEQ_WIDTH> next_seq);
}
#endif

#if defined(ACKing)
  // State that needs to be kept by dataplanes
extern SenderAckState {
  SenderAckState();
  bool sending_packet(); // if returns "true" then raise ACK flag.
  void raising_ack_flag(bit<SEQ_WIDTH> current_seq); // indicates that we're waiting for an ACK.
  bool overdue_ack(bit<SEQ_WIDTH> current_seq); // if returns "true" then relink.
}
extern ReceiverAckState {
  ReceiverAckState();
}
#endif
#if defined(NAKing)
  // State that needs to be kept by dataplanes
extern SenderNakState {
  SenderNakState();
  bool receivedNak(); // if returns "true" then relink.
}
extern ReceiverNakState {
  ReceiverNakState();
  void initSeq(bit<SEQ_WIDTH> init_seq);
  //bit<SEQ_WIDTH> lastSeq();
  void nextSeq(in bit<SEQ_WIDTH> received_seq, out bit<1> result); // if result==true then send NAK.
  //void should_relink(out bool result); // if result==true then relink.
  void relink(out bit<1> result);
}
#endif

#endif // FLIGHTPLAN_HEADER_P4_
