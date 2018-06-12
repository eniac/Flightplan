#include "fecBooster.h"
#include <stdlib.h>
#include <arpa/inet.h>

/** Static flag for checking if wharf has been enabled */
static bool wharf_enabled;

static tclass_type default_tclass = TCLASS_NULL;

struct tclass_params {
    fec_sym k;
    fec_sym h;
    int t;
    bool active;
};

/** A single entry in the table of rules matching ports/protocls to traffic classes */
struct rule_entry {
    uint16_t port;
    bool is_tcp;
    tclass_type tclass;
    bool active;
};

/** The maximum number of rules allowed in the table */
#define MAX_RULES 16

/** Accepts a rule as the first argument after the format string */
#define LOG_RULE(s, r, ...) LOG_INFO(s "\tport: %5d  tcp: %d  cls: 0x%02x  active: %d", \
                                     ##__VA_ARGS__, r.port, r.is_tcp, r.tclass, r.active)

#define LOG_CLASS(s, c, ...) LOG_INFO(s "\tk: %3d  h: %3d  t: %3d  active: %d", \
                                      ##__VA_ARGS__, c.k, c.h, c.t, c.active)

/** The table of rules */
static struct rule_entry rules[MAX_RULES];

/** The table of classes */
static struct tclass_params tclasses[TCLASS_MAX];

/** Checks if there is an entry in the class table corresponding to this class ID */
static bool valid_tclass(int tclassi) {
    if (tclassi != TCLASS_NULL && tclassi > TCLASS_MAX) {
        LOG_ERR("Tclass %d too high", tclassi);
        return false;
    }
    if (tclassi == TCLASS_NULL || tclasses[tclassi].active) {
        return true;
    }
    LOG_ERR("Unknown traffic class: %d", tclassi);
    return false;
}


/** Checks if the port and protocl of two rules match */
static bool rules_equal(struct rule_entry *r1, struct rule_entry *r2) {
    return r1->port == r2->port &&
           r1->is_tcp == r2->is_tcp;
}

/** Sets an entry in the traffic class table to have the provided k, h, and timeout */
int wharf_set_tclass(tclass_type tclass, fec_sym k, fec_sym h, int t) {
    if (tclass > TCLASS_MAX) {
         LOG_ERR("Tclass 0x%02x too high", tclass);
         return -1;
    }
    struct tclass_params new_tclass = {k, h, t, true};
    if (tclasses[tclass].active) {
        LOG_CLASS("Replacing class 0x%02x", tclasses[tclass], tclass);
        LOG_CLASS("Replacement: ", new_tclass);
        tclasses[tclass] = new_tclass;
    } else {
        LOG_CLASS("Inserting class 0x%02x", new_tclass, tclass);
        tclasses[tclass] = new_tclass;
    }

#ifndef NO_FBK
    set_fec_params(tclass, k, h);
#endif
    return 0;
}

/** Removes an entry from the traffic class table */
int wharf_delete_tclass(tclass_type tclass) {
    if (tclass > TCLASS_MAX) {
        LOG_ERR("Tclass 0x%02x too high", (int)tclass);
        return -1;
    }
    LOG_CLASS("Disabling class 0x%02x", tclasses[tclass], tclass);
    tclasses[tclass].active = false;
    return 0;
}

/** Gets the value of `k` associated with the provided traffic class.
 * Returns 0 if traffic class does not exist */
fec_sym wharf_get_k(tclass_type tclass) {
    if (tclass > TCLASS_MAX) {
        LOG_ERR("Tclass 0x%02x too high", tclass);
        return 0;
    }
    if (!tclasses[tclass].active) {
        LOG_ERR("Tclass 0x%02x not set", tclass);
        return 0;
    }
    return tclasses[tclass].k;
}

int wharf_get_t(tclass_type tclass) {
    if (tclass > TCLASS_MAX) {
        LOG_ERR("Tclass 0x%02x too high", tclass);
        return -1;
    }
    if (!tclasses[tclass].active) {
        LOG_ERR("Tclass 0x%02x not set", tclass);
        return -1;
    }
    return tclasses[tclass].t;
}

/**
 * Gets the value of k, h, and t associated with a given class.
 * If k, h, or t are NULL, will not attempt to assign them.
 * @returns 0 on success, -1 if class DNE
 */
int wharf_query_tclass(tclass_type tclass,
                       fec_sym *k, fec_sym *h, int *t) {
    if (tclass > TCLASS_MAX) {
        LOG_ERR("Tclass 0x%02x too high", tclass);
        return -1;
    }
    if (!tclasses[tclass].active) {
        LOG_ERR("Tclass 0x%02x not set", tclass);
        return -1;
    }
    if (k != NULL) {
        *k = tclasses[tclass].k;
    }
    if (h != NULL) {
        *h = tclasses[tclass].h;
    }
    if (t != NULL) {
        *t = tclasses[tclass].t;
    }
    return 0;
}

/** Enables wharf if is_enabled is true */
void wharf_set_enabled(bool is_enabled) {
    wharf_enabled = is_enabled;
}

/** Returns whether wharf is enabled */
bool wharf_get_enabled(void) {
    return wharf_enabled;
}

/** Sets the default class to which unclassified traffic is applied */
int wharf_set_default_class(tclass_type tclass) {
    if (!valid_tclass(tclass)) {
        return -1;
    }
    default_tclass = tclass;
    return 0;
}

/** Sets the port and protocol to point to the traffic class in the rules table */
int wharf_set_rule(tclass_type tclass, uint16_t port, bool is_tcp) {
    if (!valid_tclass(tclass)) {
        return -1;
    }
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

/** Removes the matching rule from the rule table */
int wharf_delete_rule(tclass_type tclass, uint16_t port, bool is_tcp) {
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

/**
 * Checks if there is a rule in the table that matches the port + protocol.
 * If not, returns default_tclass
 */
tclass_type wharf_query_rule(uint16_t port, bool is_tcp) {
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
                return default_tclass;
            }
        }
    }
    LOG_RULE("Rule has no matching entry: ", query);
    return default_tclass;
}

/** Prints current rule table to stderr */
void wharf_list_rules() {
    if (!wharf_enabled) {
        LOG_ERR("Wharf disabled");
        return;
    }
    LOG_INFO("Listing active classes:");
    int n_classes = 0;
    for (int i=0; i < TCLASS_MAX; i++) {
        if (tclasses[i].active) {
            n_classes++;
            LOG_CLASS("\t0x%02x)", tclasses[i], i);
        }
    }
    if (n_classes == 0) {
        LOG_INFO("\tNO CLASSES DEFINED");
    }
    LOG_INFO("Default traffic class: %d", default_tclass);
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

/** Parses a string to retrieve the port, protocol, and class (in that order) */
static int parse_rule_opts(char *str, tclass_type *tclass, uint16_t *port, bool *is_tcp) {
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
        if (!valid_tclass(tclassi)) {
            return -1;
        }
        *tclass = (tclass_type) tclassi;
    }
    return 0;
}

/** Parses CLI options associated with defining a class */
static int parse_class_opts(char *str, tclass_type *tclass, int *k, int *h, int *t) {
    char *tclassc = strtok(str, " ,");
    if (tclassc == NULL) {
        LOG_ERR("No tclass provided");
        return -1;
    }
    *tclass = atoi(tclassc);
    char *ki = strtok(NULL, " ,");
    if (ki == NULL) {
        LOG_ERR("No k provided");
        return -1;
    }
    *k = atoi(ki);
    char *hi = strtok(NULL, " ,");
    if (hi == NULL) {
        LOG_ERR("No h provided");
        return -1;
    }
    *h = atoi(hi);
    char *ti = strtok(NULL, " ,");
    if (ti == NULL) {
        LOG_ERR("No t provided");
        return -1;
    }
    *t = atoi(ti);
    return 0;
}


/**
 * CLI interface for rules. One of SET, DEL, LIST, QUERY, ENABLE
 */
int wharf_str_call(char *str) {
    char *cmd = strtok(str, " ");

    tclass_type tclass;
    uint16_t port;
    bool is_tcp;
    if (strcasecmp(cmd, "CLASS") == 0) {
        char *args = strtok(NULL, "");
        tclass_type tclass;
        int h, k, i;
        if (parse_class_opts(args, &tclass, &k, &h, &i) != 0) {
            return -1;
        }
        return wharf_set_tclass(tclass, k, h, i);
    } else if (strcasecmp(cmd, "DELCLASS") == 0) {
        char *args = strtok(NULL, "");
        int tclassi = atoi(args);
        return wharf_delete_tclass(tclassi);
    } else if (strcasecmp(cmd, "DEFAULT") == 0) {
        char *args = strtok(NULL, "");
        int tclassi = atoi(args);
        if (!valid_tclass(tclassi)) {
            return -1;
        }
        wharf_set_default_class((tclass_type)tclassi);
        return 0;
    } else if (strcasecmp(cmd, "SET") == 0) {
        char *args = strtok(NULL, "");
        int rtn = parse_rule_opts(args, &tclass, &port, &is_tcp);
        if (rtn < 0) {
            return -1;
        }
        return wharf_set_rule(tclass, port, is_tcp);
    } else if (strcasecmp(cmd, "DEL") == 0) {
        char *args = strtok(NULL, "");
        int rtn = parse_rule_opts(args, &tclass, &port, &is_tcp);
        if (rtn < 0) {
            return -1;
        }
        return wharf_delete_rule(tclass, port, is_tcp);
    } else if (strcasecmp(cmd, "LIST") == 0) {
        wharf_list_rules();
        return 0;
    } else if (strcasecmp(cmd, "QUERY") == 0) {
        char *args = strtok(NULL, "");
        int rtn = parse_rule_opts(args, NULL, &port, &is_tcp);
        if (rtn < 0) {
            return -1;
        }
        tclass = wharf_query_rule(port, is_tcp);
        LOG_INFO("Query returned tclass: %d", (int)tclass);
        return 0;
    } else if (strcasecmp(cmd, "ENABLE") == 0) {
        char *enablec = strtok(NULL, " ");
        if (enablec == NULL) {
            bool enabled = wharf_get_enabled();
            // Gets rid of unused variable warning when LOG_INFO disabled
            (void)enabled;
            LOG_INFO("Wharf enabled? %d", enabled);
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

/** Loads rules from a csv file.
 * Format: port, protocol, class
 */
int wharf_load_from_file(char *filename) {
    FILE *f = fopen(filename, "r");
    if (f == NULL) {
        LOG_ERR("Could not load from file: %s", filename);
        return -1;
    }
    char line[1024];
    int rtn = 0;
    while ( fgets(line, 1024, f) != NULL ) {
        char line_cp[1024];
        strcpy(line_cp, line);
        if (wharf_str_call(line) != 0) {
            LOG_ERR("Error parsing line: %s", line_cp);
            rtn = -1;
            break;
        }
    }
    fclose(f);
    wharf_list_rules();
    return rtn;
}


/** IP header starts right after ethernet header. First 4 bits are IP version */
#define IPV4_OFFSET sizeof(struct ether_header)

/** Checks that the first four bits are 0x04, ignoring the second four bits */
#define IS_IPV4(bits) (bits & (0x4)) && !(bits & !(0x4F))

/** Checks if a packet is ipv4 */
static bool is_ipv4(const u_char *packet, uint32_t pkt_len) {
    if (pkt_len < IPV4_OFFSET) {
        return false;
    }
    return IS_IPV4(packet[IPV4_OFFSET]);
}

/** Protocol starts 9 bytes into IP header */
#define PROTOCOL_OFFSET sizeof(struct ether_header) + 9
#define TCP_PROTOCOL 0x06
#define UDP_PROTOCOL 0x11

/** Checks if a packet is tcp */
static bool is_tcp(const u_char *packet, uint32_t pkt_len) {
    if (pkt_len < PROTOCOL_OFFSET) {
        return false;
    }
    return packet[PROTOCOL_OFFSET] == TCP_PROTOCOL;
}

/** Checks if a packet is udp */
static bool is_udp(const u_char *packet, uint32_t pkt_len) {
    if (pkt_len < PROTOCOL_OFFSET) {
        return false;
    }
    return packet[PROTOCOL_OFFSET] == UDP_PROTOCOL;
}

/** In both TCP and UDP, port starts 2 bytes into header.
 * This assumes that the IP header is 20 bytes long (which may not always be the case)
 */
#define PORT_OFFSET sizeof(struct ether_header) + 22

/** Returns a tcp or udp packet's port */
static uint16_t get_port(const u_char *packet, uint32_t pkt_len) {
    if (pkt_len < PORT_OFFSET) {
        return 0;
    }
    uint16_t *port = (uint16_t*)(packet + PORT_OFFSET);
    return ntohs(*port);
}

/** Prints to stderr info about a packet */
void describe_packet(const u_char *packet, uint32_t pkt_len) {
    if (is_ipv4(packet, pkt_len)) {
        LOG_INFO("PACKET IS IPV4");
    } else {
        LOG_INFO("PACKET IS NOT IPV4");
        return;
    }
    if (is_tcp(packet, pkt_len)) {
        LOG_INFO("PACKET IS TCP");
    } else if (is_udp(packet, pkt_len)) {
        LOG_INFO("PACKET IS UDP");
    } else {
        LOG_INFO("PACKET FORMAT UNKNOWN");
        return;
    }

    LOG_INFO("PORT IS %d", (int)get_port(packet, pkt_len));
}

/** Returns the traffic class to which a packet belongs */
tclass_type wharf_query_packet(const u_char  *packet, uint32_t pkt_len) {
    if (!is_ipv4(packet, pkt_len)) {
        return default_tclass;
    }
    int protocol;
    if (is_tcp(packet, pkt_len)) {
        protocol = 1;
    } else if (is_udp(packet, pkt_len)) {
        protocol = 0;
    } else {
        return default_tclass;
    }

    uint16_t port = get_port(packet, pkt_len);

    return wharf_query_rule(port, protocol);
}
