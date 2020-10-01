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
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#ifndef FLIGHTPLAN_PARSING_H
#define FLIGHTPLAN_PARSING_H

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

#include <boost/bind.hpp>
#include <boost/coroutine/coroutine.hpp>
#include <boost/none.hpp>
#include <boost/optional.hpp>
#include <boost/program_options.hpp>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include "json/single_include/nlohmann/json.hpp"

#include "table.h"
#include "network.h"

Data::BoundRel StringToBoundRel(nlohmann::json json);
Data::gamma StringToGamma(nlohmann::json json);

enum class Obj {Max, Min};
extern std::vector<std::pair<Data::Bound, Obj>> ObjOrder;

enum class Runtime {Unspecified, Full, HL};
extern Runtime runtime;

extern std::map<std::string,std::string> units_of_measurement;

extern bool show_worst_solution_too;
extern bool single_allocation;
extern bool greedy_search;
extern bool invert_order;

extern std::vector<std::string> exclude_devices;
extern std::vector<std::string> exclude_rules;

extern std::set<Data::Prop> supporting_device_classes;

extern bool verbose;
extern bool veryverbose;
extern bool trace_proof;

extern std::string performance_json_filename;
extern std::string devices_json_filename;
extern std::string network_json_filename;
extern std::string planner_config_json_filename;
extern std::string program_json_filename;

extern Data::G performance_rules;
extern Data::G program_rules;
using CFG_t = std::vector<std::pair<std::string, std::string>>;
extern CFG_t CFG;
extern std::vector<std::string> FSAliases;
extern std::map<std::string, Node*> parsed_devices;
extern std::map<std::string, std::map<std::string, std::vector<Data::BoundRel>>> port_bounds;
extern std::map<Data::Bound,double> initial_m;
extern std::map<Data::Bound,double> override_initial_m;
extern std::vector<Data::Bound> link_bound_accumulate;

extern std::map<std::string,double> deviceclass_latency;
enum class FPGAMeasure {LUTs, BRAMs, FFs};
extern std::map<std::string,std::map<FPGAMeasure,std::string>> alloctable_fpga;

extern std::string focus_switch;
extern Network network;
extern Node *focus_switch_node;

extern std::set<PortID> ports_to_ignore;

extern std::set<std::string> find_latency;
extern std::string find_cost;
extern std::string find_power;

int parse_all();

#endif // FLIGHTPLAN_PARSING_H
