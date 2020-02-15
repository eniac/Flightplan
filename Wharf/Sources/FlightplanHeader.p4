/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/
#ifndef FLIGHTPLAN_HEADER_P4_
#define FLIGHTPLAN_HEADER_P4_

// Merge comment: next 2 lines removed in adjustment
//#undef ACKing
//#undef NAKing

#define FLIGHTPLAN_VERSION_SIZE 4 /*FIXME fudge*/
#define ETHERTYPE_FLIGHTPLAN 0x2222 /*FIXME fudge*/
#define SEGMENT_DESC_SIZE 4 /*FIXME fudge*/
#define BYTE 8
#define MAX_DATAPLANE_CLIQUE_SIZE 64 /*FIXME fudge*/
#define SEQ_WIDTH 32 /*FIXME fudge*/

// Flightplan header scheme
header flightplan_h {
  // Includes Ethernet header to simplify parsing, and handling by black-box external functions that aren't aware of the Flightplan header.
  bit<48> dst;
  bit<48> src;
  bit<16> type;

//  bit<FLIGHTPLAN_VERSION_SIZE> version; // This could be spared.
//  bit<16> encapsulated_ethertype; -- This can be removed if we fully encapsulate the Ethernet frame including the original Ethernet header.
  bit<SEGMENT_DESC_SIZE> from_segment; // This is implicit in ingress port, so could be spared.
  bit<SEGMENT_DESC_SIZE> to_segment; // This is implicit in ingress port, so could be spared.
//  bit<4> pad;

  bit<BYTE> byte1;
  bit<BYTE> byte2;
  bit<BYTE> byte3;
  bit<BYTE> byte4;
  bit<BYTE> byte5;
  bit<BYTE> byte6;
  bit<BYTE> byte7;
  bit<BYTE> byte8;
  bit<BYTE> byte9;
  bit<BYTE> byte10;
  bit<BYTE> byte11;
  bit<BYTE> byte12;
  bit<BYTE> byte13;
  bit<BYTE> byte14;
  bit<BYTE> byte15;
  bit<BYTE> byte16;
  bit<BYTE> byte17;
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
#ifndef NAKing
  bit<7> pad;
#endif
#endif
#if defined(NAKing)
  bit<1> nak;
#ifdef ACKing
  bit<6> pad;
#endif
#endif
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
