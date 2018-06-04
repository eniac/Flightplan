#include "fecBooster.h"
#include <stdlib.h>

static bool wharf_enabled;

struct rule_entry {
    uint16_t port;
    bool is_tcp;
    enum traffic_class tclass;
    bool active;
};

#define MAX_RULES 16

#define LOG(s, ...) fprintf(stderr, s "\n", ##__VA_ARGS__)

#define LOG_ERR(s, ...) LOG("ERROR: " s, ##__VA_ARGS__)

#define LOG_INFO(s, ...) LOG(s, ##__VA_ARGS__)

#define LOG_RULE(s, r, ...) LOG_INFO(s "\tport: %5d  tcp: %d  cls: %d, active: %d", \
                                     ##__VA_ARGS__, r.port, r.is_tcp, r.tclass, r.active)

static struct rule_entry rules[MAX_RULES];

static bool rules_equal(struct rule_entry *r1, struct rule_entry *r2) {
    return r1->port == r2->port &&
           r1->is_tcp == r2->is_tcp;
}

void wharf_set_enabled(bool is_enabled) {
    wharf_enabled = is_enabled;
}

bool wharf_get_enabled(void) {
    return wharf_enabled;
}

int wharf_set_rule(enum traffic_class tclass, uint16_t port, bool is_tcp) {
    struct rule_entry new_rule = { port, is_tcp, tclass, true };
    for (int i=0; i < MAX_RULES; i++) {
        if (rules_equal(&rules[i], &new_rule)) {
            LOG_RULE("Replacing rule %d ", rules[i], i);
            LOG_RULE("Replacement: ", new_rule);
            rules[i] = new_rule;
            return 0;
        }
        if ( !rules[i].active ) {
            rules[i] = new_rule;
            LOG_RULE("Setting rule %d: ", new_rule, i);
            return 0;
        }
    }
    LOG_RULE("No room for new rule (%d active rules): ", new_rule, MAX_RULES);
    return -1;
}

int wharf_delete_rule(enum traffic_class tclass, uint16_t port, bool is_tcp) {
    struct rule_entry to_del = {port, is_tcp, tclass, false };
    for (int i=0; i < MAX_RULES; i++) {
        if ( rules_equal(&rules[i], &to_del) && rules[i].active && rules[i].tclass == tclass) {
            rules[i].active = false;
            LOG_RULE("Deactivating rule %d: ", to_del, i);
            return 0;
        }
    }
    LOG_RULE("No matching rule to delete: ", to_del);
    return -1;
}

enum traffic_class wharf_query_rule(uint16_t port, bool is_tcp) {
    if (!wharf_enabled) {
        LOG_INFO("Wharf disabled");
        return TCLASS_NULL;
    }
    struct rule_entry query = {port, is_tcp, TCLASS_NULL};
    for (int i=0; i < MAX_RULES; i++) {
        if (rules_equal(&rules[i], &query)) {
            if (rules[i].active) {
                LOG_RULE("Rule %d matched: ", rules[i], i);
                return rules[i].tclass;
            } else {
                LOG_RULE("Rule %d disabled: ", rules[i], i);
                return TCLASS_NULL;
            }
        }
    }
    LOG_RULE("Rule has no matching entry: ", query);
    return TCLASS_NULL;
}


void wharf_list_rules() {
    if (!wharf_enabled) {
        LOG_ERR("Wharf disabled");
        return;
    }
    LOG_INFO("Listing active rules:");
    int n_active = 0;
    for (int i=0; i < MAX_RULES; i++) {
        if (rules[i].active) {
            n_active++;
            LOG_RULE("\t%d: %d)", rules[i], n_active, i);
        }
    }
    if (n_active == 0) {
        LOG_INFO("\tNO ACTIVE RULES");
    }
}

static int parse_cmd_opts(char *str, enum traffic_class *tclass, uint16_t *port, bool *is_tcp) {
    char *portc = strtok(str, " ,");
    if (portc == NULL) {
        LOG_ERR("No port provided");
        return -1;
    }
    *port = atoi(portc);
    if (*port <= 0 || *port > 65536) {
        LOG_ERR("Invalid port provided: %s", portc);
        return -1;
    }
    char *is_tcpc = strtok(NULL, " ,");
    if (is_tcpc == NULL) {
        LOG_ERR("No protocol provided");
        return -1;
    }
    int is_tcpi = atoi(is_tcpc);
    if (is_tcpi != 0 && is_tcpi != 1) {
        LOG_ERR("Invalid protocal (1/0) provided: %s", is_tcpc);
        return -1;
    }
    *is_tcp = is_tcpi;
    if (tclass != NULL) {
        char *tclassc = strtok(NULL, " ,\n");
        if (tclassc == NULL) {
            LOG_ERR("No traffic class provided");
            return -1;
        }
        int tclassi = atoi(tclassc);
        switch (tclassi) {
            case TCLASS_ONE:
            case TCLASS_TWO:
            case TCLASS_THREE:
                break;
            default:
                LOG_ERR("Unknown traffic class: %s", tclassc);
                return -1;
        }
        *tclass = (enum traffic_class) tclassi;
    }
    return 0;
}

int wharf_load_from_file(char *filename) {
    FILE *f = fopen(filename, "r");
    if (f == NULL) {
        LOG_ERR("Could not load from file: %s", filename);
        return -1;
    }
    enum traffic_class tclass;
    uint16_t port;
    bool is_tcp;

    char line[1024];
    int rtn = 0;
    while ( fgets(line, 1024, f) != NULL ) {
        if (parse_cmd_opts(line, &tclass, &port, &is_tcp) != 0) {
            LOG_ERR("Error parsing file: %s", filename);
            rtn = -1;
            break;
        }
        if (wharf_set_rule(tclass, port, is_tcp) != 0) {
            LOG_ERR("Error setting rule from line: %s", line);
            rtn = -1;
            break;
        }
    }
    fclose(f);
    wharf_list_rules();
    return rtn;
}

int wharf_str_call(char *str) {
    char *cmd = strtok(str, " ");

    enum traffic_class tclass;
    uint16_t port;
    bool is_tcp;
    if (strcasecmp(cmd, "SET") == 0) {
        char *args = strtok(NULL, "");
        int rtn = parse_cmd_opts(args, &tclass, &port, &is_tcp);
        if (rtn < 0) {
            return -1;
        }
        return wharf_set_rule(tclass, port, is_tcp);
    } else if (strcasecmp(cmd, "DEL") == 0) {
        char *args = strtok(NULL, "");
        int rtn = parse_cmd_opts(args, &tclass, &port, &is_tcp);
        if (rtn < 0) {
            return -1;
        }
        return wharf_delete_rule(tclass, port, is_tcp);
    } else if (strcasecmp(cmd, "LIST") == 0) {
        wharf_list_rules();
        return 0;
    } else if (strcasecmp(cmd, "QUERY") == 0) {
        char *args = strtok(NULL, "");
        int rtn = parse_cmd_opts(args, NULL, &port, &is_tcp);
        if (rtn < 0) {
            return -1;
        }
        tclass = wharf_query_rule(port, is_tcp);
        LOG_ERR("Query returned tclass: %d", (int)tclass);
        return 0;
    } else if (strcasecmp(cmd, "ENABLE") == 0) {
        char *enablec = strtok(NULL, " ");
        if (enablec == NULL) {
            bool enabled = wharf_get_enabled();
            LOG_ERR("Wharf enabled? %d", enabled);
            return 0;
        }
        int enablei = atoi(enablec);;
        if (enablei != 0 && enablei != 1) {

            LOG_ERR("Invalid value (1/0) given for ENABLE: %s", enablec);
            return -1;
        }
        wharf_set_enabled(enablei);
        return 0;
    } else {
        LOG_ERR("Unknown command received: %s", str);
        return -1;
    }
}
