from paramiko import SSHClient
import arista_syntax

enter_dflow = '''enable
config
directflow'''

def mk_parser():
    parser = arista_syntax.syntax_parser()
    parser.add_argument('--counters-only', action='store_true', help='Just get directflow rule counters')
    parser.add_argument('--from-file', type=str, default=None, help='Load rules from file instead')
    parser.add_argument('--delete-only', action='store_true', help='Delete existing rules only')
    parser.add_argument('--delete-first', action='store_true', help='Delete rules before updating')
    return parser

def dflow_cmd(cmd):
    return enter_dflow + '\n' + cmd

def connect_to_arista():
    c = SSHClient()
    c.load_system_host_keys()
    c.connect('192.0.0.2', username='admin', password='password')
    return c

def get_current_flows(conn=None):
    if conn is None:
        conn = connect_to_arista()
    stdinn, stdout, stderr = conn.exec_command(dflow_cmd('show active'))
    curr_flows = stdout.read()

    key = None
    flows = {}

    for line in curr_flows.splitlines():
        if line.strip().startswith('flow'):
            key = line.split()[-1]
            flows[key] = ''
        elif key is not None:
            if line.strip() != '!':
                flows[key] += line + '\n'
    return flows

def show_current_flows(conn):
    flows = get_current_flows()
    if len(flows) == 0:
        print("No active flows")

    for k, v in flows.items():
        print("Name:\t" + k)
        print("Flow:\n" + v)

def add_flows(flows, conn=None):
    if conn is None:
        conn = connect_to_arista()

    stdi, stdo, stde = conn.exec_command(dflow_cmd('\n'.join(flows)))

    print(stdo.read())
    print(stde.read())


def clear_current_flows(conn = None):
    if conn is None:
        conn = connect_to_arista()

    flows = get_current_flows()
    cmds = []
    for flow in flows:
        cmds.append("no flow %s" % flow)

    stdi, stdo, stde = conn.exec_command(dflow_cmd('\n'.join(cmds)))

    print(stdo.read())
    print(stde.read())

def get_counters(conn=None):
    if conn is None:
        conn = connect_to_arista()

    stdi, stdo, stde = conn.exec_command('show directflow counters')
    print(stdo.read())
    print(stde.read())

def main(ports, host_cfg, from_file, do_delete, do_update, do_counters, allow_ipv6,
         ingress_mirror, egress_mirror):
    conn = connect_to_arista()
    if do_counters:
        get_counters(conn)
        return
    if do_delete:
        clear_current_flows(conn)
    if do_update:
        flows = arista_syntax.generate_rules(ports, allow_ipv6, host_cfg, ingress_mirror, egress_mirror)
        add_flows(flows, conn)
    if from_file is not None:
        flows = [x.strip('\n') for x in open(from_file).readlines()]
        add_flows(flows, conn)

    print("***** Flows after addition:")
    show_current_flows(conn)


if __name__ == '__main__':
    args = mk_parser().parse_args()
    ports = arista_syntax.ports_from_args(args)

    main(ports, args.host_cfg, args.from_file,
         do_delete = args.delete_only or args.delete_first,
         do_update = not (args.delete_only or (args.from_file is not None)),
         do_counters = args.counters_only,
         allow_ipv6 = args.allow_ipv6,
         ingress_mirror = args.ingress_mirror,
         egress_mirror = args.egress_mirror)

