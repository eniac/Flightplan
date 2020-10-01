/*
Copyright 2020 University of Pennsylvania

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Flightplanner
v0.1 Nik Sultana, UPenn, February 2019 -- Haskell prototype
v0.2 Nik Sultana, UPenn, July 2019 -- ported to C++ and expanded functionality
v0.3 Nik Sultana, UPenn, April 2020 -- rewrote solving stage
v0.4 Nik Sultana, UPenn, July 2020 -- usability improvement and better integration with analyser
*/

#include <cassert>
#include <cmath>
#include <iostream>
#include <map>
#include <set>
#include <list>
#include <vector>
#include <numeric>
#include <iostream>
#include <fstream>
#include <queue>

#include <boost/bind.hpp>
#include <boost/coroutine/coroutine.hpp>
#include <boost/none.hpp>
#include <boost/optional.hpp>
#include <boost/program_options.hpp>

#include "table.h"
#include "network.h"
#include "parsing.h"
#include "proof.h"
#include "plan.h"

#include "json/single_include/nlohmann/json.hpp"

std::string output_csv_filename = "output.csv";
std::string output_maximums_filename = "output.max";
std::ofstream output_csv_file;
std::ofstream output_maximums;

bool generate_ctrl_prog_profile = false;
bool invert_order = false;
bool trace_proof = false;

std::vector<std::string> exclude_devices;
std::vector<std::string> exclude_rules;
std::map<Data::Bound,double> override_initial_m;

void process_peer (Point peer, std::set<Data::Prop> &supporting_device_classes, std::map<Data::Prop, std::vector<Point> > &supporting_devices)
{
  std::set<Data::Prop> props = peer.node->getProps();
  int found = 0;
  Data::Prop device_class;
  for (Data::Prop supporting_device_class : supporting_device_classes) {
    if (props.find(supporting_device_class) != props.end()) {
      found++;
      device_class = supporting_device_class;
    }
  }

  assert(found <= 1); // Each device must belong to at most 1 device class.

  if (found == 1) {
    assert(!device_class.empty());
    supporting_devices[device_class].push_back(peer);
  }
}

// Scan offload devices around the FlightStart switch, categorise them, and use
// this when navigating the space.
void preprocessing (Node *beginning, std::set<PortID> &ports_to_ignore, std::set<Data::Prop> &supporting_device_classes, std::map<Data::Prop, std::vector<Point> > &supporting_devices)
{
  for (Point pt : beginning->getPoints()) {
    if (ports_to_ignore.find(pt.port) != ports_to_ignore.end()) {
      continue;
    }

    Point peer = pt.node->getExternalPeer(pt.port);
    process_peer(peer, supporting_device_classes, supporting_devices);
  }
}

void ctrl_prog_full (Solution *solution) {
  std::ofstream ctrl_prof_profile("FPControlData.yml"/*FIXME const*/, std::ios::out | std::ios::trunc);

  std::vector<std::string> seg_map;
  std::map<std::string, unsigned> seg_map_inv;
  std::queue<std::string> to_process;
  to_process.push(solution->planner->config->first_step());
  while (!to_process.empty()) {
    seg_map.push_back(to_process.front());
    seg_map_inv[to_process.front()] = seg_map.size() - 1;

    for (std::pair<std::string, std::string> entry : solution->planner->config->next_step(to_process.front())) {
      to_process.push(entry.second);
    }

    to_process.pop();
  }

  ctrl_prof_profile << "# Mapping" << std::endl;
  for (std::pair<std::string, unsigned> entry : seg_map_inv) {
    ctrl_prof_profile << "#  " << std::to_string(entry.second + 1) << " : " << entry.first << std::endl;
  }

  std::vector<Node*> nodes;
  std::set<Node*> processed;
  for (std::pair<std::string, Node*> entry : solution->alloc_node) {
    if (processed.find(entry.second) == processed.end()) {
      processed.insert(entry.second);
      nodes.push_back(entry.second);
    }
  }

  ctrl_prof_profile << std::endl;
  ctrl_prof_profile << "states:" << std::endl;
  for (Node *node : nodes) {
    ctrl_prof_profile << "  " << node->getName() << ":" << std::endl;
    for (std::pair<std::string, Node*> entry : solution->alloc_node) {
      if (node == entry.second) {
        for (std::pair<std::string, std::string> transition : solution->planner->config->CFG) {
          if (transition.first == entry.first) {
            ctrl_prof_profile << "    " << std::to_string(seg_map_inv[transition.second] + 1) << ":" << std::endl;
            ctrl_prof_profile << "      0: 0" << std::endl;
            bool found = false;
            for (Tip *tip : solution->alloc_state) {
              // FIXME this has a blind spot if we have repeated transitions, e.g., {A->B, A->B}, for instance
              //       if both the 'then' and 'else' branches flyto(B).
              if (tip->entry.first == transition.first &&
                  tip->entry.second == transition.second) {
                bool sub_found = false;
                for (Tip *next_tip : solution->alloc_state) {
                  if (next_tip->goal == transition.second) {
                    assert(nullptr != next_tip->link);
                    Point p;
                    if (next_tip->link->getA().node == next_tip->here.node) {
                      p = next_tip->link->getB();
                    } else {
                      p = next_tip->link->getA();
                    }
                    ctrl_prof_profile << "      1: " << p.port << std::endl;
                    sub_found = true;
                    break;
                  }
                }
                assert(sub_found);
                found = true;
                break;
              }
            }
            assert(found);
          }
        }
      }
    }
  }

  ctrl_prof_profile << std::endl;
  ctrl_prof_profile << "state_sequence:" << std::endl;
  for (Node *node : nodes) {
    ctrl_prof_profile << "  " << node->getName() << ":" << std::endl;
    for (std::pair<std::string, Node*> entry : solution->alloc_node) {
      if (node == entry.second) {
        for (std::pair<std::string, std::string> transition : solution->planner->config->CFG) {
          if (transition.first == entry.first) {
            ctrl_prof_profile << "    " << std::to_string(seg_map_inv[transition.second] + 1) << ":" << std::endl;
            ctrl_prof_profile << "      0: 1" << std::endl;
          }
        }
      }
    }
  }

  ctrl_prof_profile << std::endl;
  ctrl_prof_profile << "progression:" << std::endl;
  for (Node *node : nodes) {
    ctrl_prof_profile << "  " << node->getName() << ":" << std::endl;
    for (std::pair<std::string, Node*> entry : solution->alloc_node) {
      if (node == entry.second) {
        bool handled = false;
        for (std::pair<std::string, std::string> transition : solution->planner->config->CFG) {
          if (transition.first == entry.first) {
            ctrl_prof_profile << "    " << std::to_string(seg_map_inv[entry.first] + 1) << ": ";
            ctrl_prof_profile << std::to_string(seg_map_inv[transition.second] + 1);
            ctrl_prof_profile << std::endl;
            handled = true;
          }
        }

        if (!handled) {
          // Is a terminal segment
          ctrl_prof_profile << "    " << std::to_string(seg_map_inv[entry.first] + 1) << ":" << std::endl;
        }
      }
    }
  }

  ctrl_prof_profile << std::endl;
  ctrl_prof_profile << "start: " << focus_switch << std::endl;

  ctrl_prof_profile.close();
  std::cout << "Generated control-program profile." << std::endl;
}

int main (int argc, char** argv)
{
  boost::program_options::options_description desc("Options");
  desc.add_options()
      ("help", "Show this list of options")
      ("focus", boost::program_options::value<std::string>(), "Switch where the program starts execution")
      ("exclude_device", boost::program_options::value<std::vector<std::string>>(), "Exclude device(s) from the allocation")
      ("exclude_rule", boost::program_options::value<std::vector<std::string>>(), "Exclude rule(s) from the allocation")
      ("performance_json", boost::program_options::value<std::string>(), "Performance rules")
      ("devices_json", boost::program_options::value<std::string>(), "Device rules")
      ("network_json", boost::program_options::value<std::string>(), "Network topology")
      ("program_json", boost::program_options::value<std::string>(), "Program rules")
      ("planner_config_json", boost::program_options::value<std::string>(), "Planner configuration")
      ("ctrl_prog_profile", "Generate control-program profile")
      ("verbose", "Verbose output")
      ("veryverbose", "More verbose output")
      ("trace_proof", "Verbose output during proof search")
      ("initial_state", boost::program_options::value<std::vector<std::string>>(), "Initial state setting (overrides planner_config.json)")
      ("override_find_cost", boost::program_options::value<std::string>(), "Override 'find' criterion")
      ("override_find_power", boost::program_options::value<std::string>(), "Override 'find' criterion")
      ("override_find_latency", boost::program_options::value<std::vector<std::string>>(), "Override 'find' criterion")
  ;

  boost::program_options::variables_map vm;
  boost::program_options::store(boost::program_options::parse_command_line(argc, argv, desc), vm);
  boost::program_options::notify(vm);

  if (vm.count("verbose")) {
    verbose = true;
  }

  if (vm.count("veryverbose")) {
    veryverbose = true;
    verbose = true;
  }

  if (vm.count("trace_proof")) {
    trace_proof = true;
  }

  if (vm.count("focus")) {
    focus_switch = vm["focus"].as<std::string>();
  }

  if (vm.count("ctrl_prog_profile")) {
    generate_ctrl_prog_profile = true;
  }

  if (vm.count("help")) {
    std::cout << desc << std::endl;
    return 0;
  }

  if (vm.count("performance_json")) {
    performance_json_filename = vm["performance_json"].as<std::string>();
  }

  if (vm.count("devices_json")) {
    devices_json_filename = vm["devices_json"].as<std::string>();
  }

  if (vm.count("network_json")) {
    network_json_filename = vm["network_json"].as<std::string>();
  }

  if (vm.count("planner_config_json")) {
    planner_config_json_filename = vm["planner_config_json"].as<std::string>();
  }

  if (vm.count("program_json")) {
    program_json_filename = vm["program_json"].as<std::string>();
  }

  if (vm.count("exclude_device")) {
    for (std::string excluded_device : vm["exclude_device"].as<std::vector<std::string>>()) {
      exclude_devices.push_back(excluded_device);
    }
  }

  if (vm.count("exclude_rule")) {
    for (std::string excluded_rule : vm["exclude_rule"].as<std::vector<std::string>>()) {
      exclude_rules.push_back(excluded_rule);
    }
  }

  if (vm.count("initial_state")) {
    for (std::string entry : vm["initial_state"].as<std::vector<std::string>>()) {
      const std::string token_eq = "=";
      size_t pos = 0;
      if ((pos = entry.find(token_eq, 0)) != std::string::npos) {
          std::string key = entry.substr(0, pos);
          std::string value = entry.substr(pos + token_eq.length());

          double x;
          std::istringstream(value) >> x;
          Data::Bound v = key;
          assert(override_initial_m.find(v) == override_initial_m.end());
          override_initial_m[v] = x;
      } else {
        std::cerr << "Malformed --initial_state parameter: " << entry << std::endl;
        return 1;
      }
    }
  }

  int result = parse_all();
  if (0 != result) return result;

  if (override_initial_m.size() > 0) {
    for (std::pair<Data::Bound,double> entry : override_initial_m) {
      initial_m[entry.first] = entry.second;
    }
  }

  if (vm.count("override_find_cost")) {
    find_cost = vm["override_find_cost"].as<std::string>();
  }

  if (vm.count("override_find_power")) {
    find_power = vm["override_find_power"].as<std::string>();
  }

  if (vm.count("override_find_latency")) {
    find_latency.clear();
    for (std::string item : vm["override_find_latency"].as<std::vector<std::string>>()) {
      find_latency.insert(item);
    }
  }

  unsigned num_port_rules = 0;
  for (auto entry : port_bounds) {
    num_port_rules += entry.second.size();
  }
  unsigned num_prog_rules = 0;
  for (Data::RuleFamily *rule_family : program_rules) {
    num_prog_rules += rule_family->rules.size();
  }
  unsigned num_total_rules = num_port_rules + network.Links.size() +
    performance_rules.size() + num_prog_rules;
  std::cout << "Rules (" << std::to_string(num_total_rules) << "): " << std::endl;
  std::cout << "  Network = " << std::to_string(network.Links.size()) << std::endl;
  assert(network.Links.size() > 0);
  std::cout << "  Devices (" << std::to_string(parsed_devices.size()) << "):" << std::endl;
  assert(parsed_devices.size() > 0);
  std::cout << "    Port = " << std::to_string(num_port_rules) << std::endl;
  assert(num_port_rules > 0);
  std::cout << "  Performance = " << std::to_string(performance_rules.size()) << std::endl;
  assert(performance_rules.size() > 0);
  std::cout << "  Program (" << std::to_string(program_rules.size()) << "):" << std::endl;
  assert(program_rules.size() > 0);
  std::cout << "    Rules = " << std::to_string(num_prog_rules) << std::endl;
  assert(num_prog_rules > 0);

  Data::G rules = performance_rules;
  rules.insert(rules.end(), program_rules.begin(), program_rules.end());
  // FIXME re. the "beginning" variable: when we get a solution, chop off the first step of the solution since it's from an arbitrary port in the switch
  Point beginning = focus_switch_node->getPoints().front(); // NOTE pick element that arbitrarily happens to be first

  if (verbose) {
    std::cout << RulesToString(performance_rules); // NOTE Doesn't show full set of rules, we'd see the full set if we printed the contents of "rules" variable.
  }

  std::map<Data::Prop, std::vector<Point> > supporting_devices;
  preprocessing(beginning.node, ports_to_ignore, supporting_device_classes, supporting_devices);

  if (verbose) {
    std::cout << "FS to run on: " << beginning.node->toString() << std::endl;
    std::cout << "supporting_device_classes = ";
    for (Data::Prop device_class : supporting_device_classes) {
      std::cout << Data::PropToString(device_class) << " ";
    }
    std::cout << std::endl;
    std::cout << "supporting_devices = ";
    std::cout << std::endl;
    for (std::pair<Data::Prop, std::vector<Point> > devices : supporting_devices) {
      std::cout << "  " << Data::PropToString(devices.first) << ": ";
      for (Point peer : devices.second) {
        std::cout << peer.toString() << " ";
      }
      std::cout << std::endl;
    }
  }

  Config cfg;
  cfg.rules = rules;
  cfg.network = &network;
  cfg.FS = beginning.node;
  cfg.supporting_devices = supporting_devices;
  for (std::string alias : FSAliases) {
    cfg.alloc_node_seed[alias] = cfg.FS;
  }
  cfg.beginning = beginning;
  cfg.CFG = CFG;

  Planner *planner = new Planner(&cfg);
  Planner::Outcome oc = planner->plan(100/*FIXME const*/);

  std::cout << "Outcome: " << Planner::StringOfOutcome(oc) << std::endl;
  std::cout << "Solutions = " << std::to_string(planner->solutions.size()) << std::endl;

  std::list<Solution*> ordered_solutions = Planner::orderSolutions(planner->solutions);

  if (ordered_solutions.size() > 0) {
    if (greedy_search) {
      std::cout << "::(GREEDY) BEST SOLUTION::" << std::endl;
    } else if (show_worst_solution_too) {
      std::cout << "::BEST SOLUTION::" << std::endl;
    }
    std::cout << ordered_solutions.front()->toString("") << std::endl;

    std::cout << ordered_solutions.front()->toFocusedString("") << std::endl;

    if (generate_ctrl_prog_profile) {
      if (Runtime::Full == runtime) {
        Solution *solution = ordered_solutions.front();
        ctrl_prog_full(solution);
      } else {
        std::cerr << "Control-program profile generation not supported for this runtime" << std::endl;
        return 1/*FIXME const*/;
      }
    }

    if (greedy_search && show_worst_solution_too) {
      std::cerr << "show_worst_solution_too is ignored since greedy_search==true" << std::endl;
    } else if (show_worst_solution_too && ordered_solutions.size() > 1) {
      std::cout << "::WORST SOLUTION::" << std::endl;
      std::cout << ordered_solutions.back()->toString("") << std::endl;
    }

    int idx = Planner::findSolution(ordered_solutions, find_latency, find_cost, find_power);
    std::cout << "Found idx: " << std::to_string(idx) << std::endl;

    output_csv_file.open(output_csv_filename, std::ios::out | std::ios::trunc);
    output_csv_file << "Rate,Latency,Power,Cost,Area" << std::endl;
    for (Solution *solution : ordered_solutions) {
      output_csv_file << solution->toCSVString() << std::endl;
    }
    output_csv_file.close();

    output_maximums.open(output_maximums_filename, std::ios::out | std::ios::trunc);
    output_maximums << "Rate,Latency,Power,Cost,Area" << std::endl;
    output_maximums << ordered_solutions.back()->toCSVString() << std::endl;
    output_maximums << "0,0,0,0,0" << std::endl;
    output_maximums.close();
  }

  int exit_code = 1/*FIXME const*/;
  if (planner->solutions.size() > 0) {
      exit_code = 0/*FIXME const*/;
  }

  return exit_code;
}
