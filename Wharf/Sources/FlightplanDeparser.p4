/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/

control Deparser(in headers_t hdr, packet_out pkt) {
  apply
  {
    pkt.emit(hdr.eth);
    pkt.emit(hdr.fpSend1);
    pkt.emit(hdr.fpSend2);
  }
}
