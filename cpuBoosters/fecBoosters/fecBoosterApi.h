#ifndef FEC_BOOSTER_API_H_
#define FEC_BOOSTER_API_H_
#include "fecBooster.h"

int wharf_set_rule(enum traffic_class tclass, uint16_t port, bool is_tcp);
int wharf_delete_rule(enum traffic_class tclass, uint16_t port, bool is_tcp);
enum traffic_class wharf_query_rule(uint16_t port, bool is_tcp);
void wharf_list_rules();

int wharf_str_call(char *str);

#endif
