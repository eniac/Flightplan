from flightplan_p4_mininet import send_commands
import os
import yaml
import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description="Send commands to bmv2 instance running in mininet")
    parser.add_argument('config', help="Path to topological configuration yaml file")
    parser.add_argument('switch_name', help='Name of the swtich running in bmv2')

    args = parser.parse_args()

    cfgbase = os.path.dirname(os.path.realpath(args.config))
    cfg = yaml.load(open(args.config), Loader=yaml.FullLoader)

    switch_spec = cfg['switches']
    switch_items = sorted(switch_spec.items(), key = lambda x: x[0])

    base_thrift = 9090

    for i, (name, opts) in enumerate(switch_items):
        if name == args.switch_name:
            thrift_port = base_thrift + i
            cfg_path = os.path.join(cfgbase, opts['cfg'])
            break
    else:
        raise Exception("Specified name does not exist in config")

    while True:
        command = sys.stdin.readline()
        if command == '':
            break
        send_commands(thrift_port, cfg_path, [command])
        print("Sent command %s" % command)


if __name__ == '__main__':
    main()
