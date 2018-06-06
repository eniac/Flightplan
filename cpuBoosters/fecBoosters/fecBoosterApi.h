#ifndef FEC_BOOSTER_API_H_
#define FEC_BOOSTER_API_H_
#include "fecBooster.h"

int wharf_set_tclass(tclass_type tclass, fec_sym k, fec_sym h, int t);
int wharf_delete_tclass(tclass_type tclass);
int wharf_query_tclass(tclass_type tclass, fec_sym *k, fec_sym *h, int *t);
fec_sym wharf_get_k(tclass_type tclass);

int wharf_set_default_class(tclass_type tclass);
int wharf_set_rule(tclass_type tclass, uint16_t port, bool is_tcp);
int wharf_delete_rule(tclass_type tclass, uint16_t port, bool is_tcp);
bool wharf_set_enabled(bool is_enabled);
bool wharf_get_enabled();
tclass_type wharf_query_rule(uint16_t port, bool is_tcp);
void wharf_list_rules();

int wharf_load_from_file(char *filename);
int wharf_str_call(char *str);

void describe_packet(const u_char *packet, uint32_t pkt_len);
tclass_type wharf_query_packet(const u_char *packet, uint32_t pkt_len);

#endif
