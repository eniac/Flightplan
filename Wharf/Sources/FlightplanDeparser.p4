/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/

control FlightplanDeparser(packet_out pkt, in fp_headers_t hdr) {
  apply
  {
    pkt.emit(hdr.eth);
    pkt.emit(hdr.fpSend1);
    pkt.emit(hdr.fpSend2);
  }
}
