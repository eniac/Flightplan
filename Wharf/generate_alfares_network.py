#!/usr/bin/env python
#
# Generates network spec according to the scheme described by Al-Fares et al. in SIGCOMM'08
#   http://ccr.sigcomm.org/online/files/p63-alfares.pdf
#
# Nik Sultana, UPenn, February 2020
#
# NOTE:
# * Slight difference in the order in which aggregate ports are wired wrt the paper
# * Generates route, forwarding and ARP tables for each network element.
# * I made some tweaks to integrate it smoothly with our BMv2-on-Mininet system running on the tclust cluster
#   e.g., using 192 network instead of 10 because of collision with another internal network which Mininet
#         doesn't hide from its virtual nodes.
#   e.g., all hosts get full ARP table (showing all hosts) -- this can be minimised to show only the edge
#         router and the other hosts it's linked to.


import random

long_names = False # Because Mininet appears to have a 10-character maximum wrt element names.
port_num_index = 1  # Because our BMv2-on-Mininet system starts indexing ports from 1.

network_number = 192

k = float(4) # This is the only parameter to the networks described by Al-Fares et al.

p4_program = "../../build/bmv2/AlFares.json"

num_pods = k
num_switch_ports = k
pod_switches_upper = k/2
pod_switches_lower = k/2
pod_num_hosts = pod_switches_lower * (k/2)
num_core_switches = (k/2)*(k/2)

num_hosts = num_pods * pod_num_hosts

def check_int(x):
    assert x == float(int(x))
    return int(x)

k = check_int(k)
num_pods = check_int(num_pods)
num_switch_ports = check_int(num_switch_ports)
pod_switches_upper = check_int(pod_switches_upper)
pod_switches_lower = check_int(pod_switches_lower)
pod_num_hosts = check_int(pod_num_hosts)
num_core_switches = check_int(num_core_switches)
num_hosts = check_int(num_hosts)

print "# k=" + str(k)
print "# pod_switches_upper=" + str(pod_switches_upper)
print "# pod_switches_lower=" + str(pod_switches_lower)
print "# pod_num_hosts=" + str(pod_num_hosts)
print "# num_hosts=" + str(num_hosts)
assert num_hosts == ((k*k*k)/4)
print "# num_core_switches=" + str(num_core_switches)

indentation = "      " # FIXME const

CoreSwitches = []
Pods = []

macs_in_use = []
# based on https://stackoverflow.com/questions/735975/static-methods-in-python
# FIXME fix the seed of the PRNG, for deterministic yet pseudo-random output.
def generate_mac_address():
    while True:
        candidate = "02:00:00:%02x:%02x:%02x" % (random.randint(0, 255),
                             random.randint(0, 255),
                             random.randint(0, 255))
        if candidate not in macs_in_use:
            macs_in_use.append(candidate)
            break
    return candidate

class IPv4Address:
    def __init__(self, o1, o2, o3, o4):
        self.o1 = o1
        self.o2 = o2
        self.o3 = o3
        self.o4 = o4
    def toString(self):
        return str(self.o1) + "." + str(self.o2) + "." + str(self.o3) + "." + str(self.o4)

class SwitchRule:
    def __init__(self, mac_address, port):
        self.mac_address = mac_address
        self.port = port
    def toString(self):
        return self.mac_address + " -> " + str(self.port)
    @staticmethod
    def rulesString(rules):
        result = ""
        for rule in rules:
            result += indentation + rule.toString() + "\n"
        return result

class RouteRule:
    def __init__(self, ipv4_address, mask, next_hop, port, is_prefix_lookup):
        self.ipv4_address = ipv4_address
        self.mask = mask
        self.next_hop = next_hop
        self.port = port
        self.is_prefix_lookup = is_prefix_lookup
    def toString(self):
        if self.is_prefix_lookup:
            direction = "prefix"
        else:
            direction = "suffix"
        return "(" + direction + ") " + self.ipv4_address.toString() + "/" + str(self.mask) + " -> gateway " + self.next_hop.toString() + " port " + str(self.port)
    @staticmethod
    def rulesString(rules):
        result = ""
        for rule in rules:
            result += indentation + rule.toString() + "\n"
        return result
    def bmv2CommandString(self):
        if (self.ipv4_address.o1 == 0 and
                self.ipv4_address.o2 == 0 and
                self.ipv4_address.o3 == 0 and
                self.ipv4_address.o4 == 0 and
                self.mask == 0):
            # Ignore default routing rules when generating BMv2 commands, for this network.
            return ""

        prefix = "table_add ipv4_forwarding ipv4_forward"
        if self.is_prefix_lookup:
            if self.mask == 8:
                mask_str = "FF000000"
            elif self.mask == 16:
                mask_str = "FFFF0000"
            elif self.mask == 24:
                mask_str = "FFFFFF00"
            elif self.mask == 32:
                mask_str = "FFFFFFFF"
            else: raise ValueError("Unsupported mask value: " + str(self.mask))

            ipv4_hex = "%2.2X%2.2X%2.2X%2.2X" % (self.ipv4_address.o1, self.ipv4_address.o2, self.ipv4_address.o3, self.ipv4_address.o4)

            matcher = "0x" + ipv4_hex + "&&&0x" + mask_str
        else:
            matcher = "0xFFFFFF%2.2X&&&0x000000FF" % self.ipv4_address.o4
        last = " 0" # FIXME this is a priority parameter; it is optional but (the version we're using of) BMv2 seems to require it in this setting.
        return prefix + " " + matcher + " => " + self.next_hop.toString() + " " + str(self.port) + last

class Element(object):
    def __init__(self, name, ipv4_address, mask):
        self.name = name
        self.ipv4_address = ipv4_address # In this scheme the same IP address is used across all interfaces.
        self.links = {}
        self.mask = mask
        for i in range(port_num_index, k + port_num_index):
            self.links[i] = None
        self.route_rules = []
        self.switch_rules = []
        self.arp_table = []
    def stringLinks(self):
        result = ""
        for i in range(port_num_index, k + port_num_index):
            if self.links[i] != None:
                if result != "":
                    result += ", "
                result += str(i) + " | " + str(self.links[i]['mac_address']) + " => " + self.links[i]['element'].name + "(" + str(self.links[i]['port']) + ")"
        return result
    def routeRulesString(self):
        result = RouteRule.rulesString(self.route_rules)
        if result != "":
            result = "\n" + indentation + "Routes:\n" + result
        return result
    def switchRulesString(self):
        result = SwitchRule.rulesString(self.switch_rules)
        if result != "":
            result = "\n" + indentation + "Switching:\n" + result
        return result
    def arpTableString(self):
        result = ""
        for entry in self.arp_table:
            result += indentation + entry['ipv4_address'].toString() + " -> " + entry['mac_address']
        if result != "":
            result = "\n" + indentation + "ARP:\n" + result + "\n"
        return result

    def toString(self):
        return self.name + " (" + self.ipv4_address.toString() + "/" + str(self.mask) + ") " + self.stringLinks() + self.routeRulesString() + self.arpTableString() + self.switchRulesString()

class Switch(Element):
    def toString(self):
        return "switch " + super(Switch, self).toString()

class Host(Element):
    def toString(self):
        return "host " + super(Host, self).toString()

def make_core_switches():
    count = 0
    for core_switch_num_j in range(1, int(float(k)/2) + 1):
        for core_switch_num_i in range(1, int(float(k)/2) + 1):
            if long_names:
                name = "core_" + str(count)
            else:
                name = "c" + str(count)
            ipv4_address = IPv4Address(network_number, k, core_switch_num_j, core_switch_num_i)
            count += 1
            switch = Switch(name, ipv4_address, 8)
            CoreSwitches.append(switch)

def gen_core_switches_route_tables():
    for switch in CoreSwitches:
       # Based on Algorithm 2 in the paper
       for pod_num in range(0, num_pods):
           next_hop = switch.links[pod_num + port_num_index]['element'].ipv4_address
           switch.route_rules.append(RouteRule(IPv4Address(network_number,pod_num + port_num_index,0,0), 16, next_hop, pod_num + port_num_index, True))

route_table_creation_worklist = []

def gen_pod_switches_route_tables(route_table_creation_worklist):
    for entry in route_table_creation_worklist:
        switch = entry['switch']
        if entry['type'] == 'edge':
            for port_num in range(port_num_index, k + port_num_index):
                target = switch.links[port_num]['element']
                if isinstance(target, Host):
                    switch.route_rules.append(RouteRule(target.ipv4_address, 32, target.ipv4_address, port_num, True))
            # Based on Algorithm 1
            default_output_port = port_num_index
            default_next_hop = switch.links[default_output_port]['element'].ipv4_address
            switch.route_rules.append(RouteRule(IPv4Address(0,0,0,0), 0, default_next_hop, default_output_port, True))
            for host_id in range(2, k/2 + 2):
                output_port = (host_id - 2 + entry['switch_num']) % (k/2) + k/2 + port_num_index
                next_hop = switch.links[output_port]['element'].ipv4_address
                switch.route_rules.append(RouteRule(IPv4Address(0,0,0,host_id), 8, next_hop, output_port, False))
        elif entry['type'] == 'aggregate':
            # Based on Algorithm 1
            for subnet in range(0, k/2):
                output_port = k/2 + subnet + port_num_index
                next_hop = switch.links[output_port]['element'].ipv4_address
                switch.route_rules.append(RouteRule(IPv4Address(entry['network_number'],entry['pod_num'],subnet,0), 24, next_hop, output_port, True))

            default_output_port = port_num_index
            default_next_hop = switch.links[default_output_port]['element'].ipv4_address
            switch.route_rules.append(RouteRule(IPv4Address(0,0,0,0), 0, default_next_hop, default_output_port, True))

            for host_id in range(2, k/2 + 2):
                output_port = (host_id - 2 + entry['switch_num']) % (k/2) + port_num_index
                next_hop = switch.links[output_port]['element'].ipv4_address
                switch.route_rules.append(RouteRule(IPv4Address(0,0,0,host_id), 8, next_hop, output_port, False))
        else: raise ValueError("Unsupported switch type: " + entry['type'])

def link(el1, p1, el2, p2):
    assert el1.links[p1] == None
    assert el2.links[p2] == None
    # Generate different MAC address for each switch port
    el1.links[p1] = {'mac_address' : generate_mac_address(), #el1's MAC address at p1
            'element' : el2, 'port' : p2} # Link connects el1's p1 port to el2's p2 port.
    el2.links[p2] = {'mac_address' : generate_mac_address(), 'element' : el1, 'port' : p1}

    el1.switch_rules.append(SwitchRule(el2.links[p2]['mac_address'], p1))
    el2.switch_rules.append(SwitchRule(el1.links[p1]['mac_address'], p2))

    el1.arp_table.append({'ipv4_address' : el2.ipv4_address, 'mac_address' : el2.links[p2]['mac_address']})
    el2.arp_table.append({'ipv4_address' : el1.ipv4_address, 'mac_address' : el1.links[p1]['mac_address']})

def make_pod(pod_num):
    Pod = {}
    Pod['aggregate'] = []
    Pod['edge'] = []
    Pod['hosts'] = []
    aggregate_count = 0
    edge_count = 0
    host_count = 0
    for switch_num in range(0, pod_switches_lower + pod_switches_upper):
        switch_ipv4_address = IPv4Address(network_number, pod_num, switch_num, 1)

        if switch_num < pod_switches_lower:
            if long_names:
                switch_name = "pod_" + str(pod_num) + "_edge_" + str(edge_count)
            else:
                switch_name = "p" + str(pod_num) + "e" + str(edge_count)
            switch = Switch(switch_name, switch_ipv4_address, 24)
            Pod['edge'].append(switch)
            switch_port = port_num_index
            hosts = []
            for host_num in range(2, int(float(k)/2) + 2):
                if long_names:
                    host_name = "pod_" + str(pod_num) + "_host_" + str(host_count)
                else:
                    host_name = "p" + str(pod_num) + "h" + str(host_count)
                host_ipv4_address = IPv4Address(network_number, pod_num, switch_num, host_num)
                host = Host(host_name, host_ipv4_address, 24)
                host_port = port_num_index
                link(host, host_port, switch, switch_port)
                # Default route from hosts to the edge routers
                host.route_rules.append(RouteRule(IPv4Address(0,0,0,0), 0, switch.ipv4_address, host_port, True))
                Pod['hosts'].append(host)
                host_count += 1
                switch_port += 1
                hosts.append(host)
            edge_count += 1
            # Propagate ARP table to all hosts
            for host in hosts:
                for arp_entry in switch.arp_table:
                    if host.ipv4_address != arp_entry['ipv4_address']:
                        host.arp_table.append(arp_entry)
            route_table_creation_worklist.append({'type' : 'edge', 'switch' : switch, 'switch_num' : switch_num})
        else:
            if long_names:
                switch_name = "pod_" + str(pod_num) + "_aggregate_" + str(aggregate_count)
            else:
                switch_name = "p" + str(pod_num) + "a" + str(aggregate_count)
            switch = Switch(switch_name, switch_ipv4_address, 16)
            aggr_switch_num = len(Pod['aggregate'])
            for port_num in range(port_num_index, k/2 + port_num_index):
                link(CoreSwitches[(port_num - port_num_index) + (aggr_switch_num * k/2)], pod_num + port_num_index, switch, port_num)
            Pod['aggregate'].append(switch)
            port_num = k/2
            for edge_switch in Pod['edge']:
                link(edge_switch, switch_num + port_num_index, switch, port_num + port_num_index)
                port_num += 1
            aggregate_count += 1
            route_table_creation_worklist.append({'type' : 'aggregate', 'switch' : switch, 'switch_num' : switch_num, 'network_number' : network_number, 'pod_num' : pod_num})
    Pods.append(Pod)

# Create everything
make_core_switches()
for pod_num in range(0, num_pods):
    make_pod(pod_num)
gen_core_switches_route_tables()
gen_pod_switches_route_tables(route_table_creation_worklist)

## Iterate through core switches and pods, and print out configuration info
#print "Configuration (topology+routing):"
#for core_switch in CoreSwitches:
#    print core_switch.toString()
#pod_count = 0
#for pod in Pods:
#    print "Pod " + str(pod_count)
#    for element in pod['aggregate']:
#       print "    " + element.toString() 
#    for element in pod['edge']:
#       print "    " + element.toString() 
#    for element in pod['hosts']:
#       print "    " + element.toString() 
#    pod_count += 1

def print_host_yml(host):
    port_num = port_num_index
    print "    " + host.name + " :"
    print "         interfaces:"
    print "             - mac: '" + host.links[port_num]['mac_address'] + "'"
    print "               ip: " + host.ipv4_address.toString() + "/" + str(host.mask)
    print "               port: " + str(port_num)
    print "         programs:"
    print "             - cmd: \"echo 'Hello from " + host.name + "'\""
    print "               fg: True"
    p4_mininet_default_if_name = host.name + "-eth" + str(port_num)
    edge_switch = host.links[port_num]['element']
    switch_mac_address = edge_switch.links[host.links[port_num]['port']]['mac_address']
    print "             # " + edge_switch.name
    print "             - cmd: \"sudo arp -v -i " + p4_mininet_default_if_name + " -s " + edge_switch.ipv4_address.toString() + " " + switch_mac_address + "\""
    print "               fg: True"
    print "             - cmd: \"sudo route add default " + p4_mininet_default_if_name + "\""
    print "               fg: True"
#    # arp entries for other elements connected to the edge switch
#    for switch_link_idx in host.links[port_num]['element'].links:
#        switch_link =host.links[port_num]['element'].links[switch_link_idx]
#        if switch_link['element'].name != host.name:
#            target_mac_address = switch_link['element'].links[switch_link['port']]['mac_address']
#            print "             # " + switch_link['element'].name
#            print "             - cmd: \"sudo arp -v -i " + p4_mininet_default_if_name + " -s " + switch_link['element'].ipv4_address.toString() + " " + target_mac_address + "\""
    # for simplification wrt Mininet, have each host have complete ARP table
    for pod in Pods:
        for a_host in pod['hosts']:
            if a_host.name != host.name:
                target_mac_address = a_host.links[port_num_index]['mac_address'] # hosts have a since MAC
                print "             # " + a_host.name
                print "             - cmd: \"sudo arp -v -i " + p4_mininet_default_if_name + " -s " + a_host.ipv4_address.toString() + " " + target_mac_address + "\""

def print_switch_yml(switch):
    print "    " + switch.name + " :"
    print "         cfg: " + p4_program
    print "         interfaces:"
    for port_num in range(port_num_index, k + port_num_index):
        if switch.links[port_num] != None:
            print "             - link: " + switch.links[port_num]['element'].name
            print "               # ip: " + switch.ipv4_address.toString()
            print "               mac: '" + switch.links[port_num]['mac_address'] + "'"
            print "               port: " + str(port_num)
    print "         cmds:"
    print "             # Switching"
    for rule in switch.switch_rules:
        print "             - table_add mac_forwarding mac_forward_set_egress " + rule.mac_address + " => " + str(rule.port)
    print "             # ARP"
    for link_idx in switch.links:
        element = switch.links[link_idx]['element']
        element_port = switch.links[link_idx]['port']
        target_mac_address = element.links[element_port]['mac_address']
        print "             - table_add next_hop_arp_lookup arp_lookup_set_addresses " + element.ipv4_address.toString() + " => " + target_mac_address
    print "             # Routing"
    for rule in switch.route_rules:
        rule_string = rule.bmv2CommandString()
        if rule_string != "": # Some rules (default routes) don't result in BMv2 commands, since they don't matter for this network.
            print "             - " + rule_string

print "hosts:"
for pod in Pods:
    for host in pod['hosts']:
        print_host_yml(host)
print "switches:"
for switch in CoreSwitches:
        print_switch_yml(switch)
for pod in Pods:
    for switch in pod['aggregate']:
        print_switch_yml(switch)
    for switch in pod['edge']:
        print_switch_yml(switch)
