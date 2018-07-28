#ifndef FEC_P4_HPP_
#define FEC_P4_HPP_
#include <functional>

typedef std::function<void(const u_char * payload, size_t, int egress_port)> encode_forward_fn;
typedef std::function<void(const u_char * payload, size_t)> decode_forward_fn;
typedef std::function<void()> drop_fn_t;

bool get_fec_port_status(uint8_t port);
void set_fec_port_status(uint8_t port);

#endif //FEC_P4_HPP_
