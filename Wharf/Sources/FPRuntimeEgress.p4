/*
Flightplan runtime support
Nik Sultana, UPenn, February 2020
*/

// FIXME could use user-supplied metadata to distinguish between ACK and NAK.
//       Currently ACK trumps NAK, possibly leading to disagreement between
//       nak_count on each side of a link.
if (0 != meta.instance_type) {
  if (hdr.fp.state & FPAck > 0) {
    hdr.fp.state = FPAck;
  } else {
    hdr.fp.state = FPNak;
  }
  hdr.fp.state = hdr.fp.state | FPResponse;
  hdr.fp.setValid();
  return;
}
