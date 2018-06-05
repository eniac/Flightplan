#ifndef FEC_BOOSTER_API_H_
#define FEC_BOOSTER_API_H_
#include "fecBooster.h"

int wharf_set_default_class(enum traffic_class tclass);
int wharf_set_rule(enum traffic_class tclass, uint16_t port, bool is_tcp);
int wharf_delete_rule(enum traffic_class tclass, uint16_t port, bool is_tcp);
bool wharf_set_enabled(bool is_enabled);
bool wharf_get_enabled();
enum traffic_class wharf_query_rule(uint16_t port, bool is_tcp);
void wharf_list_rules();

int wharf_load_from_file(char *filename);
int wharf_str_call(char *str);

void describe_packet(const u_char *packet, uint32_t pkt_len);
enum traffic_class wharf_query_packet(const u_char *packet, uint32_t pkt_len);

#endif
