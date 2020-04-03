#! /usr/bin/env python
#Control program for a Flightplan system
#Nik Sultana, UPenn, February 2020
#
#Flightplan emits a control-data file, which is used by this program
#together with the network topology to query or alter the state of
#the system split using Flightplan.
#
# NOTE the "exit_status" and "failed_command" indicators can be misleading if the upstream
#      scripts/program don't set them correctly. In our case, send_bmv2_commands.py doesn't
#      distinguish between failure and success, so we add an extra hack to determine this --
#      see exec_switch_command().
#
# FIXME table output isn't parsed.
# FIXME could check state_sequence for unreachable states.
# FIXME could check state_sequence for loops.
# FIXME could check state_sequence + states for interfering states -- i.e., both write to same ports.
# FIXME based on table output by generate_idx_nexthop() could specify the size of the array needed on the switch.

import argparse
import re
import subprocess
import sys
import yaml

bmv2_send_command_script="/home/nsultana/2/P4Boosters/Wharf/bmv2/send_bmv2_commands.py" # FIXME const

temp_file = ".fpctl.tmp" # Can be user-configured using the --temp_file parameter.
default_flightplan_pip_nak_count_max = 5 # Can be user-configured using the --max_nak parameter.
default_flightplan_pip_ackreq_interval_exceed_max = 10 # Can be user-configured using the --max_ack_interval parameter.
default_flightplan_pip_ackreq_interval = 10 # Can be user-configured using the --ack_interval parameter.

#StopState and StartState are constants
StopState = 0
StartState = 1

offload_port_lookup_table = "offload_port_lookup"
offload_port_lookup_action = "set_offload_port"
ingress_offload_port_lookup_table = "ingress_offload_port_lookup"
egress_offload_port_lookup_table = "egress_offload_port_lookup"
egress_terminal_lookup_table = "egress_terminal_lookup"
have_hit_action = "have_hit"
incoming_heading = "incoming"
intermediate_heading = "intermediate"
outgoing_heading = "outgoing"
terminal_lookup_table = "terminal_lookup"

idx_ns_lookup_tables = ["idx_next_segment", "idx_next_segment_COPY"]
idx_ns_lookup_action = "set_idx_next_segment"

idx_pip_to_lookup_tables = ["to_segment_idx_pip", "to_segment_idx_pip_COPY"]
idx_pip_to_lookup_action = "set_idx_pip"
idx_pip_from_lookup_table = "from_segment_idx_pip"

segment_state_variable = "current_nextseg_state"
segment_state_cardinality = "num_nextseg_states"

debug_drop_variable = "reg_drop_outgoing"
debug_count_ack_relinks_variable = "reg_count_ack_relinks"

flightplan_pip_syn_next = "flightplan_pip_syn_next"
flightplan_pip_seqno = "flightplan_pip_seqno"
flightplan_pip_expecting_ack = "flightplan_pip_expecting_ack"
flightplan_pip_seqno_ackreq_sent = "flightplan_pip_seqno_ackreq_sent"
flightplan_pip_nak_count = "flightplan_pip_nak_count"
flightplan_pip_nak_count_max = "flightplan_pip_nak_count_max"
flightplan_pip_ackreq_interval = "flightplan_pip_ackreq_interval"
flightplan_pip_ackreq_interval_exceed_max = "flightplan_pip_ackreq_interval_exceed_max"
flightplan_pip_ack_relink_count = "flightplan_pip_ack_relink_count"
pip_state_variables = [flightplan_pip_syn_next, flightplan_pip_seqno, flightplan_pip_expecting_ack, flightplan_pip_seqno_ackreq_sent, flightplan_pip_nak_count, flightplan_pip_nak_count_max, flightplan_pip_ackreq_interval, flightplan_pip_ackreq_interval_exceed_max, flightplan_pip_ack_relink_count]

# FIXME add a description to each of the commands below, to be shown in command-line help.
#       in the description mention what parameters (e.g., --idx) is needed for each command.
cmd_get_state = 'get_state'
cmd_start = 'start'
cmd_stop = 'stop'
cmd_set_state = 'set_state'
cmd_transition_state = 'transition_state'
cmd_get_cardinalities = 'get_cardinalities'
cmd_set_cardinalities = 'set_cardinalities'
cmd_reset_cardinalities = 'reset_cardinalities'
cmd_clear_link_table = 'clear_link_table'
cmd_get_link_table = 'get_link_table'
cmd_set_link_table = 'set_link_table'
cmd_reset_flightplan = 'reset_flightplan'
cmd_config_flightplan = 'configure_flightplan'
cmd_show_control_spanning_tree = 'show_control_spanning_tree'
cmd_clear_idx_ns_table = 'clear_idx_ns_table'
cmd_get_idx_ns_table = 'get_idx_ns_table'
cmd_set_idx_ns_table = 'set_idx_ns_table'
cmd_show_feedback_tables = "show_feedback_tables"
cmd_clear_mirroring_sessions = 'clear_mirroring_sessions'
cmd_get_mirroring_sessions = 'get_mirroring_sessions'
cmd_set_mirroring_sessions = 'set_mirroring_sessions'
cmd_clear_idx_pip_tables = 'clear_idx_pip_tables'
cmd_get_idx_pip_tables = 'get_idx_pip_tables'
cmd_set_idx_pip_tables = 'set_idx_pip_tables'
cmd_get_pip_state = "get_pip_state"
cmd_set_pip_state = "set_pip_state"
cmd_reset_pip_state = "reset_pip_state"
cmd_check_state = 'check_state'
cmd_check_pip_state = "check_pip_state"
cmd_set_drop_outgoing = "set_drop_outgoing"
cmd_unset_drop_outgoing = "unset_drop_outgoing"
cmd_get_drop_outgoing = "get_drop_outgoing"
cmd_set_count_ack_relinks = "set_count_ack_relinks"
cmd_unset_count_ack_relinks = "unset_count_ack_relinks"
cmd_get_count_ack_relinks = "get_count_ack_relinks"

commands = [cmd_get_state, cmd_start, cmd_stop, cmd_set_state, cmd_transition_state,cmd_get_cardinalities, cmd_set_cardinalities, cmd_reset_cardinalities, cmd_clear_link_table, cmd_get_link_table, cmd_set_link_table, cmd_reset_flightplan, cmd_config_flightplan, cmd_show_control_spanning_tree, cmd_clear_idx_ns_table, cmd_get_idx_ns_table, cmd_set_idx_ns_table, cmd_show_feedback_tables, cmd_clear_mirroring_sessions, cmd_get_mirroring_sessions, cmd_set_mirroring_sessions, cmd_clear_idx_pip_tables, cmd_get_idx_pip_tables, cmd_set_idx_pip_tables, cmd_get_pip_state, cmd_set_pip_state, cmd_reset_pip_state, cmd_check_state, cmd_check_pip_state, cmd_set_drop_outgoing, cmd_unset_drop_outgoing, cmd_get_drop_outgoing]

parser = argparse.ArgumentParser(description="Control program for a Flightplan system")
parser.add_argument('topology', help="Path to YAML-encoded network topology")
parser.add_argument('control_data', help="Path to YAML-encoded control data emitted by Flightplan")
parser.add_argument('command', help="Command to the Flightplan control program. Pick from " + str(commands))
parser.add_argument('--switch', default=None, help='Switch parameter, required by some commands')
parser.add_argument('--start_switch', action='store_true', help='Use "start" swithc as the switch parameter')
parser.add_argument('--state', default=None, help='State parameter, required by some commands')
parser.add_argument('--next_segment', default=None, help='Next-segment parameter, required by some commands')
parser.add_argument('--idx', default=None, help='Index parameter, required by some commands')
parser.add_argument('--pip_state_var', default=None, help='PIP state variable, required by some commands. Must be one of ' + str(pip_state_variables))
parser.add_argument('--value', default=None, help='Value to be assigned to a specified variable, required by some commands')
parser.add_argument('--verbose', action='store_true', help='Verbose output')
parser.add_argument('--noaction', action='store_true', help='Reports commands without executing them')
parser.add_argument('--temp_file', default=None, help='Temporary file to contain BMv2 CLI output. Default: ' + temp_file)
parser.add_argument('--max_nak', default=None, help='Maximum NAKs before failing over. Default: ' + str(default_flightplan_pip_nak_count_max))
parser.add_argument('--max_ack_interval', default=None, help='Maximum sent packets after ACK before failing over. Default: ' + str(default_flightplan_pip_ackreq_interval_exceed_max))
parser.add_argument('--ack_interval', default=None, help='After how many packets sent should an ACK be requested. Default: ' + str(default_flightplan_pip_ackreq_interval))
parser.add_argument('--suppress_status_output', action='store_true', help='Suppresses the final string showing whether the command was successful')
parser.add_argument('--force', action='store_true', help='Proceed through failed (sub)commands')
parser.add_argument('--headerless_ipv4', action='store_true', help="Using bits from IPv4 header instead of Flightplan header")
parser.add_argument('--headerless', action='store_true', help="Don't assume Flightplan header is being used")
parser.add_argument('--headerless_new', action='store_true', help="More configurability about which ports relate to the program")
parser.add_argument('--directflow', action='store_true', help="Emit DirectFlow config")
args = parser.parse_args()
if None != args.temp_file:
  temp_file = args.temp_file
if None != args.max_nak:
  default_flightplan_pip_nak_count_max = int(args.max_nak)
if None != args.max_ack_interval:
  default_flightplan_pip_ackreq_interval_exceed_max = int(args.max_ack_interval)
if None != args.ack_interval:
  default_flightplan_pip_ackreq_interval = int(args.ack_interval)

def exec_switch_command(command, matcher):
  result = None
  extra_matcher = "([eE]rror)|([Ii]nvalid)" # Hack to pick up failures reported by the switch but not interpreted by intermediate script(s)
  if args.noaction:
    print command
    exit_code = 0
  else:
    if args.verbose:
      print "executing: " + command
    else:
      sys.stdout.write('.')
      sys.stdout.flush()
    exit_code = subprocess.call(command + " > " + temp_file, shell=True)
  if exit_code == 0 and not args.noaction:
    for line in open(temp_file):
      match = re.search(extra_matcher, line.rstrip())
      if None != match:
        exit_code = 1
	break;

      if matcher != None:
        match = re.search(matcher, line.rstrip())
        if None != match:
          result = match.group(1)
  return exit_code, result

def add_mirroring_session(switch, session, port):
  command = "echo 'mirroring_add " + str(session) + " " + str(port) + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  return exec_switch_command(command, None)

def delete_mirroring_session(switch, session):
  command = "echo 'mirroring_delete " + str(session) + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  return exec_switch_command(command, None)

def get_mirroring_session(switch, session):
  command = "echo 'mirroring_get " + str(session) + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  subfail, _ = exec_switch_command(command, None)
  result = None
  if not subfail and not args.noaction:
    with open(temp_file, 'r') as file:
      result = file.read() # FIXME crude -- output is not parsed
  return subfail, result

# For a given switch calculate session+port info to invoke add_mirroring_session and delete_mirroring_session
# use the "control spanning tree" for this, from which we derive paths for feedback to flow.
# e.g.:
#   * FPoffload doesn't ACK-probe p0e0
#   * p0e0 shouldn't send NAK to FPoffload
#NOTE:
# * no "session" is required for forward feedback path.
# * a link that is judged to support feedback (by spanning tree) should ahve PIP state at both ends -- on each participating dataplane.
# * forward table's "key" is to_segment.
# * backward table's "key" is formed of both from_segment and to_segment.
def generate_feedback_table_acknak(tree, switch, idx_offset, result_acc):
  session = 0
  for entry in tree:
    if entry['to_element'] == switch and not entry['loop']:
      result_acc.append({'forward' : False, 'from_segment' : entry['from_segment'], 'to_segment' : entry['to_segment'], 'idx_pip' : idx_offset, 'session' : session, 'expected-in-port' : entry['to_port']})
      session += 1
      idx_offset += 1
  return idx_offset
def generate_feedback_table_ackreq(tree, switch, idx_offset, result_acc):
  next_segs = []
  for entry in tree:
    if entry['from_element'] == switch and not entry['loop']:
      if entry['to_segment'] not in next_segs:
        next_segs.append(entry['to_segment'])
        result_acc.append({'forward' : True, 'to_segment' : entry['to_segment'], 'idx_pip' : idx_offset})
        idx_offset += 1
  return idx_offset

def generate_feedback_table(control_spanning_tree, switch):
  idx = 0
  backward_table = []
  forward_table = []
  idx = generate_feedback_table_acknak(control_spanning_tree, switch, idx, backward_table)
  idx = generate_feedback_table_ackreq(control_spanning_tree, switch, idx, forward_table)
  return backward_table, forward_table

def generate_combined_feedback_table(control_spanning_tree, switch):
  backward_table, forward_table = generate_feedback_table(control_spanning_tree, switch)
  return backward_table + forward_table

def show_feedback_table(feedback_table):
  indentation = "  "
  for entry in feedback_table:
    if entry['forward']:
      print indentation + "to_segment:" + str(entry['to_segment']) + " | idx_pip:" + str(entry['idx_pip'])
    else:
      print indentation + "from_segment:" + str(entry['from_segment']) + " to_segment:" + str(entry['to_segment']) + " | idx_pip:" + str(entry['idx_pip']) + " session:" + str(entry['session']) + "->expected-in-port:" + str(entry['expected-in-port'])

def show_feedback_tables_for_switch(control_spanning_tree, switch):
  backward_table, forward_table = generate_feedback_table(control_spanning_tree, switch)
  print "Back:"
  show_feedback_table(backward_table)
  print "Forward:"
  show_feedback_table(forward_table)

def dot_control_spanning_tree_body(tree):
  result = ""
  for entry in tree:
    if entry['loop']:
      result += "  " + entry['from_element'] + " -> " + entry['to_element'] + "[style=\"dotted\"]; // loop\n"
    else:
      result += "  " + entry['from_element'] + " -> " + entry['to_element'] + "; // port " + str(entry['from_port']) + " -> port " + str(entry['to_port']) + "\n"
  return result

def dot_control_spanning_tree(control_data, tree):
  result = "// Generated by fpctl.py from the UPenn Flightplan system\n"
  result += "digraph {\n"
  result += "  graph[pad=\"0.5\", nodesep=\"1\", ranksep=\"2\",overlap=false];\n"
  result += "  layout=\"dot\";\n"
  result += "  splines=ortho;\n"
  result += "  " + control_data['start'] + "[style=\"bold\"];\n"
  result += dot_control_spanning_tree_body(tree)
  result += "}"
  return result

def get_from_segment(control_data, switch, to_segment):
  result = None
  for from_segment in control_data['progression'][switch]:
    if control_data['progression'][switch][from_segment] == to_segment:
      if None != result:
        if from_segment == result:
          raise Exception("Illegal progression: repeated progression from " + str(from_segment) + " to " + str(to_segment) + " in switch " + switch)
        else:
          raise Exception("Illegal progression: both " + str(result) + " and " + str(from_segment) + " progress to " + str(to_segment) + " in switch " + switch)
      else:
        result = from_segment
  return result

def generate_control_spanning_tree(topology, control_data, start, visited, tree_acc):
  new_visited = visited
  new_visited.append(start)
  for next_segment in control_data['states'][start]:
    from_segment = get_from_segment(control_data, start, next_segment)
    for state in control_data['states'][start][next_segment]:
      if state == 0: continue
      next_switch = None
      for link in topology['switches'][start]['interfaces']:
        if link['port'] == control_data['states'][start][next_segment][state]:
          next_switch = link['link']
          next_port = None
          # NOTE finding next_port is a hack since our software simulator doesn't mention the exact
          #      explicit port we connect to on the target element. A name-resolution process takes
          #      place, which can be ambiguous if there are multiple links.
          for link in topology['switches'][next_switch]['interfaces']:
            if link['link'] == start:
              next_port = link['port']
              break
          if None == next_port:
            raise Exception("Topology mismatch: switch " + start + " has no link back from " + next_switch + " wrt out-link on port " + str(control_data['states'][start][next_segment][state]) + " for next_segment " + str(next_segment) + " in state " + str(state))
            break
      if None == next_switch:
        raise Exception("Topology mismatch: switch " + start + " has no port " + str(control_data['states'][start][next_segment][state]) + " for next_segment " + str(next_segment) + " in state " + str(state))
      if next_switch not in new_visited:
        tree_acc.append({'from_element': start, 'to_element': next_switch, 'loop': False, 'from_port': + control_data['states'][start][next_segment][state], 'to_port': next_port, 'from_segment' : from_segment, 'to_segment': next_segment})
        generate_control_spanning_tree(topology, control_data, next_switch, new_visited, tree_acc)
      else:
        tree_acc.append({'from_element': start, 'to_element': next_switch, 'loop': True, 'from_port': + control_data['states'][start][next_segment][state], 'to_port': next_port, 'from_segment' : from_segment, 'to_segment': next_segment})

def get_switch_var(control_data, switch, register_name, register_idx = None):
  idx_string = ""
  if register_idx != None:
    idx_string = str(register_idx)
    matcher = "^" + register_name + "\[" + idx_string + "\]= (.*)$"
  else:
    matcher = "^" + register_name + "= (.*)$"
  command = "echo 'register_read " + register_name + " " + idx_string + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  return exec_switch_command(command, matcher)

def set_switch_var(control_data, switch, register_name, register_idx, register_value):
  command = "echo 'register_write " + register_name + " " + str(register_idx) + " " + str(register_value) + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  return exec_switch_command(command, None)

def generate_idx_nexthop(control_data, switch):
  next_segments = []
  idx = 0
  idx_ns_table = {}
  for next_segment in control_data['states'][switch]:
    if next_segment not in next_segments:
      idx_ns_table[next_segment] = idx # This is the key line
      idx += 1
      next_segments.append(next_segment)
  return idx_ns_table

def clear_mirroring_sessions_switch(control_spanning_tree, switch):
  failed_command = False
  backward_table, forward_table = generate_feedback_table(control_spanning_tree, switch)
  for entry in backward_table:
    assert(not entry['forward'])
    subfail, _ = delete_mirroring_session(switch, entry['session'])
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def clear_mirroring_sessions(control_data, control_spanning_tree):
  failed_command = False
  for switch in control_data['states']:
    subfail, _ = clear_mirroring_sessions_switch(control_spanning_tree, switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def get_mirroring_sessions_switch(control_spanning_tree, switch):
  failed_command = False
  result = []
  backward_table, forward_table = generate_feedback_table(control_spanning_tree, switch)
  for entry in backward_table:
    assert(not entry['forward'])
    subfail, subresult = get_mirroring_session(switch, entry['session'])
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
    if not args.noaction: assert(None != subresult)
    result.append(subresult)
  return failed_command, result

def set_mirroring_sessions_switch(control_spanning_tree, switch):
  failed_command = False
  backward_table, forward_table = generate_feedback_table(control_spanning_tree, switch)
  for entry in backward_table:
    assert(not entry['forward'])
    subfail, _ = add_mirroring_session(switch, entry['session'], entry['expected-in-port'])
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def set_mirroring_sessions(control_data, control_spanning_tree):
  failed_command = False
  for switch in control_data['states']:
    subfail, _ = set_mirroring_sessions_switch(control_spanning_tree, switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def table_clear(switch, table):
  command = "echo 'table_clear " + table + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  return exec_switch_command(command, None)

def table_add(switch, table, action, keys, values):
  command = "echo 'table_add " + table + " " + action + " " + ' '.join(keys) + " => " + ' '.join(values) + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  return exec_switch_command(command, None)

def table_dump(switch, table):
  command = "echo 'table_dump " + table + "' | python " + bmv2_send_command_script + " " + args.topology + " " + switch
  subfail, _ = exec_switch_command(command, None)
  result = None
  if not subfail and not args.noaction:
    with open(temp_file, 'r') as file:
      result = file.read() # FIXME crude -- output is not parsed
  return subfail, result

def clear_idx_ns_table(switch):
  failed_command = False
  for idx_ns_lookup_table in idx_ns_lookup_tables:
    if failed_command and not args.force: break
    failed_command, _ = table_clear(switch, idx_ns_lookup_table)
  return failed_command, None

def clear_idx_ns_tables(control_data):
  failed_command = False
  for switch in control_data['states']:
    subfail, _ = clear_idx_ns_table(switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def get_idx_ns_table(switch):
  return table_dump(switch, idx_ns_lookup_tables[0]) # NOTE we ignore the copy

def get_idx_ns_tables(control_data):
  failed_command = False
  result = []
  for switch in control_data['states']:
    subfail, subresult = get_idx_ns_table(switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
    result.append({'switch' : switch, 'result' : subresult})
  return failed_command, result

def set_idx_ns_table(switch, idx_ns_table):
  failed_command = False
  for next_segment in idx_ns_table:
    if failed_command and not args.force: break
    for idx_ns_lookup_table in idx_ns_lookup_tables:
      if failed_command and not args.force: break
      failed_command, _ = table_add(switch, idx_ns_lookup_table, idx_ns_lookup_action, [str(next_segment)], [str(idx_ns_table[next_segment])])
  return failed_command, None

def set_idx_ns_tables(control_data):
  failed_command = False
  for switch in control_data['states']:
    subfail, _ = set_idx_ns_table(switch, generate_idx_nexthop(control_data, switch))
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def clear_idx_pip_tables_switch(switch):
  failed_command = False
  for idx_pip_to_lookup_table in idx_pip_to_lookup_tables:
    if failed_command and not args.force: break
    failed_command, _ = table_clear(switch, idx_pip_to_lookup_table)

  if not failed_command or args.force:
    failed_command, _ = table_clear(switch, idx_pip_from_lookup_table)
  return failed_command, None

def clear_idx_pip_tables_allswitches(control_data):
  failed_command = False
  for switch in control_data['states']:
    subfail, _ = clear_idx_pip_tables_switch(switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def get_idx_pip_tables_switch(switch):
  result = {}
  failed_command, subresult = table_dump(switch, idx_pip_to_lookup_tables[0]) # NOTE ignoring copy
  result['idx_pip_to_lookup_table'] = subresult
  if not failed_command or args.force:
    failed_command, subresult = table_dump(switch, idx_pip_from_lookup_table)
    result['idx_pip_from_lookup_table'] = subresult
  return failed_command, result

def set_idx_pip_tables_switch(control_spanning_tree, switch):
  failed_command = False
  backward_table, forward_table = generate_feedback_table(control_spanning_tree, switch)
  for entry in backward_table:
    assert(not entry['forward'])
    subfail, _ = table_add(switch, idx_pip_from_lookup_table, idx_pip_to_lookup_action, [str(entry['from_segment']), str(entry['to_segment'])], [str(entry['idx_pip'])])
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  if not failed_command or args.force:
    for entry in forward_table:
      assert(entry['forward'])
      if failed_command and not args.force: break
      for idx_pip_to_lookup_table in idx_pip_to_lookup_tables:
        if failed_command and not args.force: break
        failed_command, _ = table_add(switch, idx_pip_to_lookup_table, idx_pip_to_lookup_action, [str(entry['to_segment'])], [str(entry['idx_pip'])])
  return failed_command, None

def set_idx_pip_tables_allswitches(control_data, control_spanning_tree):
  failed_command = False
  for switch in control_data['states']:
    subfail, _ = set_idx_pip_tables_switch(control_spanning_tree, switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def set_switch_state(control_data, switch, next_segment, new_state):
  if args.verbose:
    print("set_switch_state on " + switch + " of next_segment " + str(next_segment) + " to " + str(new_state))
  failed_command = False
  register_idx = generate_idx_nexthop(control_data, switch)[next_segment]
  exit_code, result = set_switch_var(control_data, switch, segment_state_variable, register_idx, new_state)
  if 0 != exit_code:
    failed_command = True
  return failed_command, result

def get_switch_state(control_data, switch, next_segment):
  if args.verbose:
    print("get_switch_state on " + switch)
  failed_command = False
  register_idx = generate_idx_nexthop(control_data, switch)[next_segment]
  exit_code, result = get_switch_var(control_data, switch, segment_state_variable, register_idx)
  if 0 != exit_code:
    failed_command = True
  return failed_command, result

def get_switch_states(control_data, switch):
  if args.verbose:
    print("get_switch_states on " + switch)
  failed_command = False
  result = []
  for next_segment in control_data['states'][switch]:
    subfail, subresult = get_switch_state(control_data, switch, next_segment)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
    result.append({'next_segment': next_segment, 'result' : subresult})
  return failed_command, result

def set_switch_states(control_data, switch, new_state):
  if args.verbose:
    print("set_switch_states on " + switch)
  failed_command = False
  for next_segment in control_data['states'][switch]:
    subfail, _ = set_switch_state(control_data, switch, next_segment, new_state)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def get_switches_states(control_data, switch_opt, next_segment_opt):
  if args.verbose:
    print("get_switches_states on " + str(switch_opt) + " and segment " + str(next_segment_opt))
  failed_command = False
  result = []
  if None != switch_opt and None != next_segment_opt:
    return get_switch_state(control_data, switch_opt, int(next_segment_opt))
  elif None != switch_opt and None == next_segment_opt:
    return get_switch_states(control_data, switch_opt)
  elif None == switch_opt and None != next_segment_opt:
    # In this case the command can't fail, we exclude subresults for which the query failed,
    # since the targetted switch might have not had the register.
    # FIXME can improve this by first checking if the query makes sense on the
    #       target switch, and avoiding the query if it doesn't.
    for switch in control_data['states']:
      subfail, subresult = get_switch_state(control_data, switch, int(next_segment_opt))
      if (not subfail and None != subresult) or args.force:
        result.append({'switch' : switch, 'result' : subresult})
  else:
    assert (None == switch_opt and None == next_segment_opt)
    # In this case the command fails if any of the subqueries fail.
    for switch in control_data['states']:
      subfail, subresult = get_switch_states(control_data, switch)
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
      result.append({'switch' : switch, 'result' : subresult})
  return failed_command, result

def set_switches_states(control_data, switch_opt, next_segment_opt, new_state):
  if args.verbose:
    print("set_switches_states on " + str(switch_opt) + " and segment " + str(next_segment_opt) + " to " + str(new_state))
  failed_command = False
  if None != switch_opt and None != next_segment_opt:
    return set_switch_state(control_data, switch_opt, int(next_segment_opt), new_state)
  elif None != switch_opt and None == next_segment_opt:
    return set_switch_states(control_data, switch_opt, new_state)
  elif None == switch_opt and None != next_segment_opt:
    for switch in control_data['states']:
      subfail, _ = set_switch_state(control_data, switch, int(next_segment_opt), new_state)
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
  else:
    assert (None == switch_opt and None == next_segment_opt)
    for switch in control_data['states']:
      subfail, _ = set_switch_states(control_data, switch, new_state)
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
  return failed_command, None

def transition_state(control_data, switch, next_segment):
  failed_command, current_state = get_switch_state(control_data, switch, next_segment)
  if failed_command: # args.force has no effect here, since we cannot obtain the current_state
    return failed_command, None
  current_state = int(current_state)

  try:
    next_state = control_data['state_sequence'][switch]
  except KeyError:
    print "Invalid switch: " + switch
    exit(1)

  try:
    next_state = control_data['state_sequence'][switch][next_segment]
  except KeyError:
    print "Invalid next_segment at switch " + switch + ": " + str(next_segment)
    exit(1)

  try:
    next_state = control_data['state_sequence'][switch][next_segment][current_state]
  except KeyError:
    if args.verbose:
      print("No further next states for next_segment " + str(next_segment) + " on switch " + switch + ": transitioning to state " + str(StopState))
    next_state = 0

  if next_state == current_state:
    print "Self-loop in the state_sequence of the Control Data"
    return True, current_state
  if args.verbose:
    print("Transitioning from state " + str(current_state) + " to " + str(next_state) + " on switch " + switch + " for next_segment " + str(next_segment))
  return set_switch_state(control_data, switch, next_segment, next_state)

def get_switch_cardinalities(control_data, switch):
  if args.verbose:
    print("get_switch_cardinalities on " + switch)
  failed_command = False
  result = []
  for next_segment in control_data['states'][switch]:
    register_idx = generate_idx_nexthop(control_data, switch)[next_segment]
    exit_code, subresult = get_switch_var(control_data, switch, segment_state_cardinality, register_idx)
    subfail = 0 != exit_code
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
    result.append({'to_segment': next_segment, 'result' : subresult})
  return failed_command, result

def get_cardinalities(control_data):
  if args.verbose:
    print("get_cardinalities on " + switch)
  failed_command = False
  result = []
  for switch in control_data['states']:
    subfail, subresult = get_switch_cardinalities(control_data, switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
    result.append({'switch': switch, 'result' : subresult})
  return failed_command, result

def set_switch_cardinalities(control_data, switch, reset = False):
  if args.verbose:
    print("set_switch_cardinalities on " + switch)
  failed_command = False
  result = []
  for next_segment in control_data['states'][switch]:
    register_idx = generate_idx_nexthop(control_data, switch)[next_segment]
    if reset:
      cardinality = 0
    else:
      cardinality = len(control_data['states'][switch][next_segment])
    exit_code, _ = set_switch_var(control_data, switch, segment_state_cardinality, register_idx, str(cardinality))
    subfail = 0 != exit_code
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def set_cardinalities(control_data, reset = False):
  failed_command = False
  for switch in control_data['states']:
    subfail, subresult = set_switch_cardinalities(control_data, switch, reset)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def clear_link_table(switch):
  failed_command = False
  failed_command, _ = table_clear(switch, offload_port_lookup_table)
  if failed_command and not args.force: return failed_command, None
  if args.headerless_new:
    failed_command, _ = table_clear(switch, ingress_offload_port_lookup_table)
    if failed_command and not args.force: return failed_command, None
    failed_command, _ = table_clear(switch, egress_offload_port_lookup_table)
    if failed_command and not args.force: return failed_command, None
  return failed_command, None

def clear_link_tables(control_data):
  failed_command = False
  for switch in control_data['states']:
    subfail, subresult = clear_link_table(switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def get_link_table(switch):
  failed_command = False
  failed_command, _ = table_dump(switch, offload_port_lookup_table)
  if failed_command and not args.force: return failed_command, None
  if args.headerless_new:
    failed_command, _ = table_dump(switch, ingress_offload_port_lookup_table)
    if failed_command and not args.force: return failed_command, None
    failed_command, _ = table_dump(switch, egress_offload_port_lookup_table)
    if failed_command and not args.force: return failed_command, None
  return failed_command, None

def get_link_tables(control_data):
  failed_command = False
  result = []
  for switch in control_data['states']:
    subfail, subresult = get_link_table(switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
    result.append({'switch' : switch, 'result' : subresult})
  return failed_command, result

def set_link_table_headerless(control_data, switch):
  failed_command = False
  for in_port in control_data['states'][switch]:
    if failed_command and not args.force: break
    state = control_data['states'][switch][in_port]['state']
    offload_port = control_data['states'][switch][in_port]['port']
    failed_command, _ = table_add(switch, offload_port_lookup_table, offload_port_lookup_action, [str(in_port)], [str(state), str(offload_port)])
  return failed_command, None

def set_terminal_table_headerless(control_data, switch): # FIXME this feature is a bit hackish
  failed_command = False
  failed_command, _ = table_clear(switch, terminal_lookup_table)
  if failed_command and not args.force: return failed_command, None
  failed_command, _ = table_add(switch, terminal_lookup_table, offload_port_lookup_action, [str(control_data['end_port'])], ["1", str(control_data['terminal_port'])]) # FIXME const
  return failed_command, None

def set_egress_terminal_table_headerless(control_data, switch): # FIXME this feature is a bit hackish
  failed_command = False
  failed_command, _ = table_clear(switch, egress_terminal_lookup_table)
  if failed_command and not args.force: return failed_command, None
  failed_command, _ = table_add(switch, egress_terminal_lookup_table, have_hit_action, [str(control_data['end_port'])], ["1"]) # FIXME const
  return failed_command, None

def set_link_cotable_headerless(control_data, switch, table, heading):
  failed_command = False
  if None == control_data['states'][switch][heading]: return False, None
  for in_port in control_data['states'][switch][heading]:
    if failed_command and not args.force: break
    state = control_data['states'][switch][heading][in_port]['state']
    offload_port = control_data['states'][switch][heading][in_port]['port']
    failed_command, _ = table_add(switch, table, offload_port_lookup_action, [str(in_port)], [str(state), str(offload_port)])
  return failed_command, None

def set_link_table(control_data, switch):
  failed_command = False
  if args.headerless_new:
    if switch == control_data['start']:
      failed_command, _ = set_link_cotable_headerless(control_data, switch, offload_port_lookup_table, incoming_heading)
      if not failed_command or args.force: failed_command, _ = set_link_cotable_headerless(control_data, switch, ingress_offload_port_lookup_table, intermediate_heading)
      if not failed_command or args.force: failed_command, _ = set_link_cotable_headerless(control_data, switch, egress_offload_port_lookup_table, outgoing_heading)
    else:
      failed_command, _ = set_link_table_headerless(control_data, switch)
  elif args.headerless:
    failed_command, _ = set_link_table_headerless(control_data, switch)
  else:
    for next_segment in control_data['states'][switch]:
      if failed_command and not args.force: break
      if args.headerless_ipv4:
        offload_port = control_data['states'][switch][next_segment]
        subfail, _ = table_add(switch, offload_port_lookup_table, offload_port_lookup_action, [str(next_segment)], [str(offload_port)])
        failed_command = failed_command or subfail
        if failed_command and not args.force: break
      else:
        for state in control_data['states'][switch][next_segment]:
          offload_port = control_data['states'][switch][next_segment][state]
          subfail, _ = table_add(switch, offload_port_lookup_table, offload_port_lookup_action, [str(next_segment), str(state)], [str(offload_port)])
          failed_command = failed_command or subfail
          if failed_command and not args.force: break
  return failed_command, None

def set_link_tables(control_data):
  failed_command = False
  for switch in control_data['states']:
    subfail, subresult = set_link_table(control_data, switch)
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def get_pip_state(control_data, switch, idx_pip, pip_state_var_opt):
  if None != pip_state_var_opt:
    return get_switch_var(control_data, switch, pip_state_var_opt, idx_pip)
  else:
    failed_command = False
    result = []
    for pip_variable in pip_state_variables:
      subfail, subresult = get_switch_var(control_data, switch, pip_variable, idx_pip)
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
      result.append({pip_variable : subresult})
    return failed_command, {str(idx_pip) : result}

def get_pip_state_idxopt(control_data, control_spanning_tree, switch, idx_pip_opt, pip_state_var_opt):
  failed_command = False
  result = None
  if None != idx_pip_opt:
    subfail, subresult = get_pip_state(control_data, switch, idx_pip_opt, pip_state_var_opt)
    failed_command = failed_command or subfail
    if not failed_command: result = subresult
  else:
    switch_result = []
    for entry in generate_combined_feedback_table(control_spanning_tree, switch):
      subfail, subresult = get_pip_state(control_data, switch, entry['idx_pip'], pip_state_var_opt)
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
      switch_result.append(subresult)
    if not failed_command: result = switch_result
  return failed_command, result

def get_pip_state_opt(control_data, control_spanning_tree, switch_opt, idx_pip_opt, pip_state_var_opt):
  failed_command = False
  result = []
  if None != switch_opt and None != idx_pip_opt:
    failed_command, result = get_pip_state(control_data, switch_opt, idx_pip_opt, pip_state_var_opt)
  elif None == switch_opt:
    for switch in control_data['states']:
      subfail, switch_result = get_pip_state_idxopt(control_data, control_spanning_tree, switch, idx_pip_opt, pip_state_var_opt)
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
      result.append({switch : switch_result})
  elif None != switch_opt:
    failed_command, result = get_pip_state_idxopt(control_data, control_spanning_tree, switch_opt, idx_pip_opt, pip_state_var_opt)
  return failed_command, result

def set_pip_state(control_data, switch, idx_pip, pip_variable, value):
  return set_switch_var(control_data, switch, pip_variable, idx_pip, value)

def reset_pip_state(control_data, switch, idx_pip):
  reset_configuration = {flightplan_pip_syn_next : 1,
      flightplan_pip_seqno : 0,
      flightplan_pip_expecting_ack : 0,
      flightplan_pip_seqno_ackreq_sent : 0,
      flightplan_pip_nak_count : 0,
      flightplan_pip_nak_count_max : default_flightplan_pip_nak_count_max,
      flightplan_pip_ackreq_interval : default_flightplan_pip_ackreq_interval,
      flightplan_pip_ackreq_interval_exceed_max : default_flightplan_pip_ackreq_interval_exceed_max}

  failed_command = False
  for pip_variable in reset_configuration:
    subfail, _ = set_pip_state(control_data, switch, idx_pip, pip_variable, str(reset_configuration[pip_variable]))
    failed_command = failed_command or subfail
    if failed_command and not args.force: break
  return failed_command, None

def reset_pip_state_idxopt(control_data, control_spanning_tree, switch, idx_pip_opt):
  failed_command = False
  if None != idx_pip_opt:
    subfail, _ = reset_pip_state(control_data, switch, idx_pip_opt)
    failed_command = failed_command or subfail
  else:
    for entry in generate_combined_feedback_table(control_spanning_tree, switch):
      subfail, _ = reset_pip_state(control_data, switch, entry['idx_pip'])
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
  return failed_command, None

def reset_pip_state_opt(control_data, control_spanning_tree, switch_opt, idx_pip_opt):
  failed_command = False
  if None != switch_opt and None != idx_pip_opt:
    failed_command, _ = reset_pip_state(control_data, switch_opt, idx_pip_opt)
  elif None == switch_opt:
    for switch in control_data['states']:
      subfail, _ = reset_pip_state_idxopt(control_data, control_spanning_tree, switch, idx_pip_opt)
      failed_command = failed_command or subfail
      if failed_command and not args.force: break
  elif None != switch_opt:
    failed_command, _ = reset_pip_state_idxopt(control_data, control_spanning_tree, switch_opt, idx_pip_opt)
  return failed_command, None

def set_flag(flag, control_data, switch, next_segment, new_state):
  if args.verbose:
    print("set_flag for " + flag + " on " + switch + " of next_segment " + str(next_segment))
  failed_command = False
  register_idx = generate_idx_nexthop(control_data, switch)[next_segment]
  exit_code, result = set_switch_var(control_data, switch, flag, register_idx, new_state)
  if 0 != exit_code:
    failed_command = True
  return failed_command, result

def get_flag(flag, control_data, switch, next_segment):
  if args.verbose:
    print("get_flag for " + flag + " on " + switch)
  failed_command = False
  register_idx = generate_idx_nexthop(control_data, switch)[next_segment]
  exit_code, result = get_switch_var(control_data, switch, flag, register_idx)
  if 0 != exit_code:
    failed_command = True
  return failed_command, result

def unset_flag_switch(flag, control_data, switch, next_segment_opt):
  if None == next_segment_opt:
    failed_command = False
    for next_segment in control_data['states'][switch]:
      failed_command, _ = set_flag(flag, control_data, switch, next_segment, 0)
      if failed_command and not args.force: break
    return failed_command, None
  else:
    return set_flag(flag, control_data, switch, int(next_segment_opt), 0)

def unset_flag(flag, control_data, switch_opt, next_segment_opt):
  if None == switch_opt:
    for switch in control_data['states']:
      failed_command, _ = unset_flag_switch(flag, control_data, switch, next_segment_opt)
      if failed_command and not args.force: break
    return failed_command, None
  else:
    return unset_flag_switch(flag, control_data, switch_opt, next_segment_opt)

def generate_directflow_config_segment(topology, control_data, segment_name, result):
  result.append("# (Beginning rules for heading '" + segment_name + "'")
  start_switch = control_data['start']
  if None != control_data['states'][start_switch][segment_name]:
    for inport in control_data['states'][start_switch][segment_name]:
      outport = control_data['states'][start_switch][segment_name][inport]['port']
      outdevice = None
      for interface in topology['switches'][start_switch]['interfaces']:
        if outport == interface['port']:
          outdevice = interface['link']
          break
      assert(None != outdevice)
      flowname = start_switch + "_" + str(inport) + "_" + str(outport) + "_" + outdevice
      result.append("# Forwarding from port " + str(inport) + " --> port " + str(outport))
      result.append("flow " + flowname)
      suffix = "/1" # FIXME const
      result.append("match input interface ethernet " + str(inport) + suffix)
      result.append("action output interface ethernet " + str(outport) + suffix)
      result.append("exit")
  result.append("# (Ending rules for heading '" + segment_name + "'")

def generate_directflow_config(topology, control_data):
  result = ["# DirectFlow configuration script generated by fpctl"]
  result.append("directflow")
  generate_directflow_config_segment(topology, control_data, incoming_heading, result)
  generate_directflow_config_segment(topology, control_data, intermediate_heading, result)
  generate_directflow_config_segment(topology, control_data, outgoing_heading, result)
  result.append("# End of DirectFlow configuration script generated by fpctl")
  result.append("show active rules")
  return result

def main():
  assert(not ((args.headerless and args.headerless_ipv4) or (args.headerless and args.headerless_new) or (args.headerless_new and args.headerless_ipv4)))

  control_data = yaml.load(open(args.control_data), Loader=yaml.FullLoader)

  if not (args.headerless or args.headerless_new):
    assert(len(control_data['states']) == len(control_data['state_sequence']))
    for switch in control_data['states']:
      assert(len(control_data['states'][switch]) == len(control_data['state_sequence'][switch]))

  if args.headerless_new:
    assert(None != control_data['end_port'] and None != control_data['terminal_port'])

  topology = yaml.load(open(args.topology), Loader=yaml.FullLoader)
  control_spanning_tree = []
  if not (args.headerless_ipv4 or args.headerless or args.headerless_new):
    generate_control_spanning_tree(topology, control_data, control_data['start'], [], control_spanning_tree)

  if args.start_switch:
    assert(None == args.switch)
    args.switch = control_data['start']

  failed_command = False
  result = None

  if args.directflow:
    assert(args.headerless_new)
    if cmd_config_flightplan == args.command:
      for line in generate_directflow_config(topology, control_data): # FIXME clunky
        print line
      exit(int(True)) # FIXME clunky
    else:
      # FIXME print errors on stderr
      print("Flag '--directflow' only supported for command '" + cmd_config_flightplan + "'")
      exit(1)

  if cmd_start == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print warnings on stderr
      print("WARNING: Command '" + args.command + "' has no effect in headerless mode")
    failed_command, _ = set_switches_states(control_data, args.switch, args.next_segment, StartState)
  elif cmd_stop == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print warnings on stderr
      print("WARNING: Command '" + args.command + "' has no effect in headerless mode")
    failed_command, _ = set_switches_states(control_data, args.switch, args.next_segment, StopState)
  elif cmd_set_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    failed_command, result = set_switches_states(control_data, args.switch, args.next_segment)
  elif cmd_transition_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.next_segment:
      print("Need to provide --next_segment parameter")
      exit(1)
    failed_command, result = transition_state(control_data, args.switch, int(args.next_segment))
  elif cmd_get_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    failed_command, result = get_switches_states(control_data, args.switch, args.next_segment)
  elif cmd_get_cardinalities == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = get_cardinalities(control_data)
    else:
      failed_command, result = get_switch_cardinalities(control_data, args.switch)
  elif cmd_set_cardinalities == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = set_cardinalities(control_data)
    else:
      failed_command, result = set_switch_cardinalities(control_data, args.switch)
  elif cmd_reset_cardinalities == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = set_cardinalities(control_data, True)
    else:
      failed_command, result = set_switch_cardinalities(control_data, args.switch, True)
  elif cmd_clear_link_table == args.command:
    if None == args.switch:
      failed_command, result = clear_link_tables(control_data)
    else:
      failed_command, result = clear_link_table(args.switch)
  elif cmd_get_link_table == args.command:
    if None == args.switch:
      failed_command, result = get_link_tables(control_data)
    else:
      failed_command, result = get_link_table(args.switch)
  elif cmd_set_link_table == args.command:
    if None == args.switch:
      failed_command, result = set_link_tables(control_data)
    else:
      failed_command, result = set_link_table(control_data, args.switch)
    if not failed_command or args.force:
      if args.headerless_new:
        failed_command, result = set_egress_terminal_table_headerless(control_data, control_data['start'])
        if not failed_command or args.force:
          failed_command, result = set_terminal_table_headerless(control_data, control_data['start'])
  elif cmd_clear_idx_ns_table == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = clear_idx_ns_tables(control_data)
    else:
      failed_command, result = clear_idx_ns_table(args.switch)
  elif cmd_get_idx_ns_table == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = get_idx_ns_tables(control_data)
    else:
      failed_command, result = get_idx_ns_table(args.switch)
  elif cmd_set_idx_ns_table == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = set_idx_ns_tables(control_data)
    else:
      failed_command, result = set_idx_ns_table(args.switch, generate_idx_nexthop(control_data, switch))
  elif cmd_clear_mirroring_sessions == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, _ = clear_mirroring_sessions(control_data, control_spanning_tree)
    else:
      failed_command, _ = clear_mirroring_sessions_switch(control_spanning_tree, args.switch)
  elif cmd_get_mirroring_sessions == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      assert(False) # TODO
    else:
      failed_command, result = get_mirroring_sessions_switch(control_spanning_tree, args.switch)
  elif cmd_set_mirroring_sessions == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, _ = set_mirroring_sessions(control_data, control_spanning_tree)
    else:
      failed_command, _ = set_mirroring_sessions_switch(control_spanning_tree, args.switch)
  elif cmd_clear_idx_pip_tables == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = clear_idx_pip_tables_allswitches(control_data)
    else:
      failed_command, result = clear_idx_pip_tables_switch(args.switch)
  elif cmd_get_idx_pip_tables == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      assert(False) # TODO
    else:
      failed_command, result = get_idx_pip_tables_switch(args.switch)
  elif cmd_set_idx_pip_tables == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      failed_command, result = set_idx_pip_tables_allswitches(control_data, control_spanning_tree)
    else:
      failed_command, result = set_idx_pip_tables_switch(control_spanning_tree, args.switch)
  elif cmd_reset_flightplan == args.command:
    new_args = filter(lambda x: x != args.command, sys.argv)
    if "--suppress_status_output" not in new_args: new_args.append("--suppress_status_output")
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      command_sequence = [cmd_clear_link_table]
    else:
      command_sequence = [cmd_clear_idx_pip_tables, cmd_clear_idx_ns_table, cmd_clear_link_table, cmd_set_cardinalities, cmd_clear_mirroring_sessions, cmd_reset_pip_state, cmd_unset_drop_outgoing, cmd_unset_count_ack_relinks, cmd_stop]
    for command in command_sequence:
      args_instance = list(new_args)
      args_instance.append(command)
      if not args.verbose:
        sys.stdout.write('.')
        sys.stdout.flush()
      exit_code = subprocess.call(' '.join(args_instance), shell=True)
      failed_command = 0 != exit_code
      if failed_command and not args.force: break
  elif cmd_config_flightplan == args.command:
    new_args = filter(lambda x: x != args.command, sys.argv)
    if "--suppress_status_output" not in new_args: new_args.append("--suppress_status_output")
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      command_sequence = [cmd_set_link_table]
    else:
      command_sequence = [cmd_set_idx_pip_tables, cmd_set_idx_ns_table, cmd_set_link_table, cmd_set_cardinalities, cmd_set_mirroring_sessions, cmd_reset_pip_state, cmd_unset_drop_outgoing, cmd_unset_count_ack_relinks, cmd_stop]
    for command in command_sequence:
      args_instance = list(new_args)
      args_instance.append(command)
      if not args.verbose:
        sys.stdout.write('.')
        sys.stdout.flush()
      exit_code = subprocess.call(' '.join(args_instance), shell=True)
      failed_command = 0 != exit_code
      if failed_command and not args.force: break
  elif cmd_show_control_spanning_tree == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    print dot_control_spanning_tree(control_data, control_spanning_tree)
  elif cmd_show_feedback_tables == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None != args.switch:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None != args.switch:
      show_feedback_tables_for_switch(control_spanning_tree, args.switch)
    else:
      for switch in control_data['states']:
        print "Beginning tables for " + switch
        show_feedback_tables_for_switch(control_spanning_tree, switch)
        print "Ended tables for " + switch
  elif cmd_get_pip_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    failed_command, result = get_pip_state_opt(control_data, control_spanning_tree, args.switch, args.idx, args.pip_state_var)
  elif cmd_set_pip_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.idx:
      print("Need to provide --idx parameter")
      exit(1)
    if None == args.pip_state_var:
      print("Need to provide --pip_state_var parameter")
      exit(1)
    else:
        if args.pip_state_var not in pip_state_variables:
          print("Invalid --pip_state_var parameter: must be one of " + str(pip_state_variables))
          exit(1)
    if None == args.value:
      print("Need to provide --value parameter")
      exit(1)
    failed_command, result = set_pip_state(control_data, args.switch, args.idx, args.pip_state_var, args.value)
  elif cmd_reset_pip_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    failed_command, result = reset_pip_state_opt(control_data, control_spanning_tree, args.switch, args.idx)
  elif cmd_check_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.next_segment:
      print("Need to provide --next_segment parameter")
      exit(1)
    if None == args.value:
      print("Need to provide --value parameter")
      exit(1)
    failed_command, result = get_switches_states(control_data, args.switch, args.next_segment)
    if not failed_command:
      failed_command = not (int(result) == int(args.value))
    result = None
  elif cmd_check_pip_state == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.idx:
      print("Need to provide --idx parameter")
      exit(1)
    if None == args.pip_state_var:
      print("Need to provide --pip_state_var parameter")
      exit(1)
    if None == args.value:
      print("Need to provide --value parameter")
      exit(1)
    failed_command, result = get_pip_state_opt(control_data, control_spanning_tree, args.switch, args.idx, args.pip_state_var)
    if not failed_command:
      failed_command = not (int(result) == int(args.value))
    result = None
  elif cmd_set_drop_outgoing == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.next_segment:
      print("Need to provide --next_segment parameter")
      exit(1)
    failed_command, result = set_flag(debug_drop_variable, control_data, args.switch, int(args.next_segment), 1)
  elif cmd_unset_drop_outgoing == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    failed_command, result = unset_flag(debug_drop_variable, control_data, args.switch, args.next_segment)
  elif cmd_get_drop_outgoing == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.next_segment:
      print("Need to provide --next_segment parameter")
      exit(1)
    failed_command, result = get_flag(debug_drop_variable, control_data, args.switch, int(args.next_segment))
  elif cmd_set_count_ack_relinks == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.next_segment:
      print("Need to provide --next_segment parameter")
      exit(1)
    failed_command, result = set_flag(debug_count_ack_relinks_variable, control_data, args.switch, int(args.next_segment), 1)
  elif cmd_unset_count_ack_relinks == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    failed_command, result = unset_flag(debug_count_ack_relinks_variable, control_data, args.switch, args.next_segment)
  elif cmd_get_count_ack_relinks == args.command:
    if args.headerless_ipv4 or args.headerless or args.headerless_new:
      # FIXME print errors on stderr
      print("Command '" + args.command + "' not supported in headerless mode")
      exit(1)
    if None == args.switch:
      print("Need to provide --switch parameter")
      exit(1)
    else:
      try:
        control_data['state_sequence'][args.switch]
      except KeyError:
        print("Invalid switch name: " + args.switch)
        exit(1)
    if None == args.next_segment:
      print("Need to provide --next_segment parameter")
      exit(1)
    failed_command, result = get_flag(debug_count_ack_relinks_variable, control_data, args.switch, int(args.next_segment))

  else:
    print("Unrecognised command: " + args.command)
    exit(1)

  if not args.suppress_status_output:
    print("Success: " + str(not failed_command))
  if not failed_command and None != result:
    print("Result: " + str(result))
  exit(int(failed_command))

main()
