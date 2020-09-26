/*
Flightplanner
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#include "parsing.h"

std::set<PortID> ports_to_ignore;

std::vector<std::pair<Data::Bound, Obj>> ObjOrder;

Runtime runtime = Runtime::Unspecified;

std::map<std::string,std::string> units_of_measurement;

bool show_worst_solution_too = false;
bool greedy_search = false;
bool single_allocation = false;

std::set<Data::Prop> supporting_device_classes;

std::map<std::string,double> deviceclass_latency;
std::map<std::string,std::map<FPGAMeasure,std::string>> alloctable_fpga;

std::vector<Data::Bound> link_bound_accumulate;

std::set<std::string> find_latency;
std::string find_cost;
std::string find_power;

Data::BoundRel StringToBoundRel(nlohmann::json json)
{
  if (!json["lt"].is_null()) {
    json = json["lt"];
    double x;
    std::istringstream((std::string)(json.at(1))) >> x;
    Data::Bound v = Data::StringToBound((std::string)(json.at(0)));
    return Data::BoundRel::mk_LtVX(v, x);
  }

  if (!json["gt"].is_null()) {
    json = json["gt"];
    double x;
    std::istringstream((std::string)(json.at(1))) >> x;
    Data::Bound v = Data::StringToBound((std::string)(json.at(0)));
    return Data::BoundRel::mk_GtVX(v, x);
  }

  std::cerr << "Unrecognised JSON: " << json << std::endl;
  assert(0);
}

Data::gamma StringToGamma(nlohmann::json json)
{
  struct Param {
    std::string op;
    std::string x1;
    std::string x2;
    std::string x3;
  };
  std::vector<Param> params;
  for (nlohmann::json::iterator it = json.begin(); it != json.end(); ++it) {
    Param param;
    bool processed = false;
    if (!(*it)["aP"].is_null()) {
      // Assign after plus
      assert(false == processed);
      param.op = "aP";
      param.x1 = (*it)["aP"][0];
      param.x2 = (*it)["aP"][1];
      processed = true;
    }
    if (!(*it)["aM"].is_null()) {
      // Assign after multiply
      assert(false == processed);
      param.op = "aM";
      param.x1 = (*it)["aM"][0];
      param.x2 = (*it)["aM"][1];
      processed = true;
    }
    if (!(*it)["aF"].is_null()) {
      // Assign FPGA measure
      assert(false == processed);
      param.op = "aF";
      param.x1 = (*it)["aF"][0];
      param.x2 = (*it)["aF"][1];
      param.x3 = (*it)["aF"][2];
      processed = true;
    }
    if (!(*it)["a"].is_null()) {
      // Assign
      assert(false == processed);
      param.op = "a";
      param.x1 = (*it)["a"][0];
      param.x2 = (*it)["a"][1];
      processed = true;
    }
    if (!(*it)["aO"].is_null()) {
      // Assign Once per Device
      assert(false == processed);
      param.op = "aO";
      param.x1 = (*it)["aO"][0];
      param.x2 = (*it)["aO"][1];
      processed = true;
    }
    if (false == processed) {
      std::cerr << "Unrecognised JSON: " << json << std::endl;
    }
    assert(true == processed);
    params.push_back(param);
  }
  return [params](Data::state m, Point *point, Data::SolutionState* solstate) -> Data::state {
      Data::state m2 = m;
      for (Param param : params) {
        bool processed = false;
        if ("aP" == param.op) {
          assert(false == processed);
          double x;
          std::istringstream(param.x2) >> x;
          Data::Bound v = Data::StringToBound(param.x1);
          m2[v] = m[v] + x;
          processed = true;
        }
        if ("aM" == param.op) {
          assert(false == processed);
          double x;
          std::istringstream(param.x2) >> x;
          Data::Bound v = Data::StringToBound(param.x1);
          m2[v] = m[v] * x;
          processed = true;
        }
        if ("aF" == param.op) {
          assert(false == processed);
          double x1;
          std::istringstream(param.x1) >> x1;
          double x2;
          std::istringstream(param.x2) >> x2;
          double x3;
          std::istringstream(param.x3) >> x3;
          increment_FPGA_usage(x1, x2, x3, m2, point, solstate);
          processed = true;
        }
        if ("aO" == param.op) {
          assert(false == processed);
          double x;
          std::istringstream(param.x2) >> x;
          Data::Bound v = Data::StringToBound(param.x1);
          if (0 == solstate->node_m[point->node][v]) {
            solstate->node_m[point->node][v] = x;

            // FIXME hackish way of accumulating solution-wide state, across several nodes.
            solstate->sol_m[v] = solstate->sol_m[v] + x;
          }

          processed = true;
        }
        if ("a" == param.op) {
          assert(false == processed);
          double x;
          std::istringstream(param.x2) >> x;
          Data::Bound v = Data::StringToBound(param.x1);
          m2[v] = x;
          processed = true;
        }
        if (false == processed) {
          std::cerr << "Unrecognised op: " << param.op << std::endl;
        }
        assert(true == processed);
      }
      return m2;};
}

bool verbose = false;
bool veryverbose = false;

const std::string default_performance_json_filename = "performance.json";
const std::string default_devices_json_filename = "devices.json";
const std::string default_network_json_filename = "network_tofino.json";
const std::string default_planner_config_json_filename = "planner_config.json";
const std::string default_program_json_filename = "program.json";

std::string performance_json_filename;
std::string devices_json_filename;
std::string network_json_filename;
std::string planner_config_json_filename;
std::string program_json_filename;

std::string focus_switch;
Network network;
Node *focus_switch_node = nullptr;

Data::G performance_rules;
Data::G program_rules;
std::vector<std::string> FSAliases;
std::vector<std::pair<std::string, std::string>> CFG;
std::map<std::string, Node*> parsed_devices;
std::map<std::string, std::map<std::string, std::vector<Data::BoundRel>>> port_bounds;
std::map<Data::Bound,double> initial_m;

int parse_all() {
  if (performance_json_filename.empty()) {
    performance_json_filename = default_performance_json_filename;
    std::cerr << "Using default --performance_json: " << performance_json_filename << std::endl;
  }

  if (devices_json_filename.empty()) {
    devices_json_filename = default_devices_json_filename;
    std::cerr << "Using default --devices_json: " << devices_json_filename << std::endl;
  }

  if (network_json_filename.empty()) {
    network_json_filename = default_network_json_filename;
    std::cerr << "Using default --network_json: " << network_json_filename << std::endl;
  }

  if (planner_config_json_filename.empty()) {
    planner_config_json_filename = default_planner_config_json_filename;
    std::cerr << "Using default --planner_config_json: " << planner_config_json_filename << std::endl;
  }

  if (program_json_filename.empty()) {
    program_json_filename = default_program_json_filename;
    std::cerr << "Using default --program_json: " << program_json_filename << std::endl;
  }

  std::ifstream file(planner_config_json_filename);
  nlohmann::json planner_config_json;
  file >> planner_config_json;
  if (verbose) {
    std::cout << planner_config_json.dump() << std::endl;
  }
  file.close();

  for (nlohmann::json::iterator it = planner_config_json["Initial State"].begin(); it != planner_config_json["Initial State"].end(); ++it) {
    //std::cerr << "JSON(k)=" << it.key() << std::endl;
    //std::cerr << "JSON(v)=" << it.value() << std::endl;
    double x;
    std::istringstream((std::string)(it.value())) >> x;
    Data::Bound v = Data::StringToBound((std::string)(it.key()));
    assert(initial_m.find(v) == initial_m.end());
    initial_m[v] = x;
  }

  for (nlohmann::json::iterator it = planner_config_json["link_bound_accumulate"].begin(); it != planner_config_json["link_bound_accumulate"].end(); ++it) {
    link_bound_accumulate.push_back(*it);
  }

  if (!planner_config_json["show_worst_solution_too"].is_null()) {
    show_worst_solution_too = planner_config_json["show_worst_solution_too"];
  }

  if (!planner_config_json["greedy_search"].is_null()) {
    greedy_search = planner_config_json["greedy_search"];
  }

  if (!planner_config_json["single_allocation"].is_null()) {
    single_allocation = planner_config_json["single_allocation"];
  }

  // FIXME i assume this data is being provided  
  find_cost = planner_config_json["find"]["cost"];
  find_power = planner_config_json["find"]["power"];
  for (nlohmann::json::iterator it = planner_config_json["find"]["latency"].begin(); it != planner_config_json["find"]["latency"].end(); ++it) {
    find_latency.insert((std::string)*it);
  }

//  if (!planner_config_json["Runtime"].is_null()) {
//    if ("Full" == planner_config_json["Runtime"]["name"]) {
//      runtime = Runtime::Full;
//    } else if ("HL" == planner_config_json["Runtime"]["name"]) {
//      runtime = Runtime::HL;
//      // FIXME pick up other runtime-specific parameters
//    } else {
//      std::cerr << "Unrecognised runtime: " << planner_config_json["Runtime"] << std::endl;
//      return 1;
//    }
//  }
//
//  if (Runtime::Unspecified == runtime) {
//    std::cerr << "Runtime has not been specified in " << planner_config_json_filename << std::endl;
//    return 1;
//  }

  for (nlohmann::json::iterator it = planner_config_json["Units"].begin(); it != planner_config_json["Units"].end(); ++it) {
    units_of_measurement[it.key()] = it.value();
  }

  for (int idx = 0; idx < planner_config_json["Order"].size(); ++idx) {
    bool processed = false; // Ensure we only ever encounter a single entry in each idx.
    for (nlohmann::json::iterator it = planner_config_json["Order"][idx].begin(); it != planner_config_json["Order"][idx].end(); ++it) {
      assert(!processed);

      std::string obj_str = it.value();
      Obj obj;
      if ("min" == obj_str) {
        obj = Obj::Min;
      } else if ("max" == obj_str) {
        obj = Obj::Max;
      } else {
        assert(false);
      }

      Data::Bound v = Data::StringToBound((std::string)(it.key()));

      ObjOrder.push_back(std::pair<Data::Bound, Obj>(v, obj));

      processed = true;
    }
  }

  for (int idx = 0; idx < planner_config_json["Supporting Device Classes"].size(); ++idx) {
    supporting_device_classes.insert(Data::StringToProp(planner_config_json["Supporting Device Classes"][idx]));
  }

  if (planner_config_json["Supporting Device Classes"].size() == 0) {
    std::cerr << "'Supporting Device Classes' is empty" << std::endl;
    return 1;
  }

  for (int idx = 0; idx < planner_config_json["excluded_ports"].size(); ++idx) {
    std::string port = planner_config_json["excluded_ports"][idx];
    ports_to_ignore.insert(port);
  }

  for (std::pair<Data::Bound, Obj> entry : ObjOrder) {
    if (Obj::Min != entry.second && Obj::Max != entry.second) {
      assert(false);
    }
  }

  for (nlohmann::json::iterator it = planner_config_json["Rough Latency Offsets"].begin(); it != planner_config_json["Rough Latency Offsets"].end(); ++it) {
    deviceclass_latency[it.key()] = it.value();
  }

  for (nlohmann::json::iterator it = planner_config_json["AllocatableFPGA"].begin(); it != planner_config_json["AllocatableFPGA"].end(); ++it) {
    alloctable_fpga[it.key()][FPGAMeasure::LUTs] = it.value()["LUTs"];
    alloctable_fpga[it.key()][FPGAMeasure::BRAMs] = it.value()["BRAMs"];
    alloctable_fpga[it.key()][FPGAMeasure::FFs] = it.value()["FFs"];
  }

  file.open(performance_json_filename);
  nlohmann::json performance_json;
  file >> performance_json;
  if (verbose) {
    std::cout << performance_json.dump() << std::endl;
  }
  file.close();

  for (nlohmann::json::iterator it = performance_json.begin(); it != performance_json.end(); ++it) {
    Data::RuleFamily *rule_family = new Data::RuleFamily();
    rule_family->name = (*it)["name"];
    rule_family->conclusion = Data::StringToProp((*it)["conclusion"]);

    Data::RuleInstance rule;
    rule.family = rule_family;

    std::set<Data::Prop> props;
    for (int i = 0; i < (*it)["props"].size(); ++i) {
      std::string prop_str = (*it)["props"][i];
      Data::Prop prop = Data::StringToProp(prop_str);
      rule.props.push_back(prop);
    }

    for (int i = 0; i < (*it)["bounds"].size(); ++i) {
      rule.bounds.push_back(StringToBoundRel((*it)["bounds"][i]));
    }

    rule.g = StringToGamma((*it)["g"]);

    rule_family->rules.push_back(rule);
    performance_rules.push_back(rule_family);
  }

  file.open(devices_json_filename);
  nlohmann::json devices_json;
  file >> devices_json;
  if (verbose) {
    std::cout << devices_json.dump() << std::endl;
  }
  file.close();

  for (nlohmann::json::iterator it = devices_json.begin(); it != devices_json.end(); ++it) {
    std::string name = (*it)["node"];
    assert(parsed_devices.find(name) == parsed_devices.end());

    std::set<Data::Prop> props;
    for (int i = 0; i < (*it)["provides"]["props"].size(); ++i) {
      std::string prop_str = (*it)["provides"]["props"][i];
      Data::Prop prop = Data::StringToProp(prop_str);
      props.insert(prop);
    }

    std::vector<Data::BoundRel> bound_rels; // FIXME assuming this info is blank in the JSON

    Node *node = new Node(name, props, bound_rels);
    parsed_devices[name] = node;

    assert(!focus_switch.empty());
    if (focus_switch == name) {
      assert(nullptr == focus_switch_node);
      focus_switch_node = node;
    }

    int num_ports = (*it)["ports"].size();
    for (int i = 0; i < num_ports; ++i) {
      nlohmann::json port = (*it)["ports"][i];
      std::string port_name = port["port"];
      port_bounds[name][port_name].push_back(StringToBoundRel(port["requires"]["bounds"].at(0)));
    }
  }

  if (nullptr == focus_switch_node) {
    std::cerr << "--focus " << focus_switch << " mentioned a non-existant switch" << std::endl;
    return 1;
  }

  file.open(network_json_filename);
  nlohmann::json network_json;
  file >> network_json;
  if (verbose) {
    std::cout << network_json.dump() << std::endl;
  }
  file.close();

  for (nlohmann::json::iterator it = network_json.begin(); it != network_json.end(); ++it) {
    std::string nodeA_name = (*it)["node"];
    std::string nodeB_name = (*it)["linked"]["node"];
    std::string portA_name = (*it)["port"];
    std::string portB_name = (*it)["linked"]["port"];

    assert(parsed_devices.find(nodeA_name) != parsed_devices.end());
    assert(parsed_devices.find(nodeB_name) != parsed_devices.end());
    assert(port_bounds.find(nodeA_name) != port_bounds.end());
    assert(port_bounds.find(nodeB_name) != port_bounds.end());

    Node* nodeA = parsed_devices[nodeA_name];
    Node* nodeB = parsed_devices[nodeB_name];

    assert(port_bounds[nodeA_name].find(portA_name) != port_bounds[nodeA_name].end());
    assert(port_bounds[nodeB_name].find(portB_name) != port_bounds[nodeB_name].end());

    std::vector<Data::BoundRel> boundsA = port_bounds[nodeA_name][portA_name];
    std::vector<Data::BoundRel> boundsB = port_bounds[nodeB_name][portB_name];

    Link *link = new Link(nodeA, portA_name, boundsA, nodeB, portB_name, boundsB);
  }

  focus_switch_node->formNetwork(network);
  if (network.Links.size() == 0) {
    std::cerr << "--focus " << focus_switch << " is isolated from the network?" << std::endl;
    return 1;
  }

  file.open(program_json_filename);
  nlohmann::json program_json;
  file >> program_json;
  if (verbose) {
    std::cout << program_json.dump() << std::endl;
  }
  file.close();

  if ("Full" == program_json["Parameters"]["flightplan_runtime"]) {
    runtime = Runtime::Full;
  } else if ("HL" == program_json["Parameters"]["flightplan_runtime"]) {
    runtime = Runtime::HL;
    // FIXME pick up other runtime-specific parameters
  } else {
    std::cerr << "Unrecognised runtime: " << program_json["Parameters"]["flightplan_runtime"] << std::endl;
    return 1;
  }

  if (Runtime::Unspecified == runtime) {
    std::cerr << "Runtime has not been specified in " << program_json_filename << std::endl;
    return 1;
  }

  for (int idx = 0; idx < program_json["CFG"].size(); ++idx) {
    for (nlohmann::json::iterator it = program_json["CFG"][idx].begin(); it != program_json["CFG"][idx].end(); ++it) {
      CFG.push_back(std::pair<std::string, std::string>(it.key(), it.value()));
    }
  }

  for (int idx = 0; idx < program_json["FlightStartAliases"].size(); ++idx) {
    FSAliases.push_back(program_json["FlightStartAliases"][idx]);
  }

  if (FSAliases.empty()) {
    std::cerr << "FlightStartAliases is empty" << std::endl;
    return 1;
  }

  for (int idx = 0; idx < program_json["Abstract program"].size(); ++idx) {
    for (nlohmann::json::iterator it = program_json["Abstract program"][idx].begin(); it != program_json["Abstract program"][idx].end(); ++it) {

      Data::RuleFamily *rule_family = new Data::RuleFamily();
      rule_family->name = it.key();
      rule_family->conclusion = Data::StringToProp(it.key());

      for (int rule_idx = 0; rule_idx < it.value().size(); ++rule_idx) {
        Data::RuleInstance rule;
        rule.family = rule_family;

        nlohmann::json family_member = it.value()[rule_idx];
        for (int prop_idx = 0; prop_idx < family_member["Props"].size(); ++prop_idx) {
          nlohmann::json prop_str = family_member["Props"][prop_idx];
          rule.props.push_back(Data::StringToProp((std::string)(prop_str)));
        }

        rule.bounds = {};
        rule.g = [](Data::state m, Point *point, Data::SolutionState* solstate) -> Data::state {return m;};

        rule_family->rules.push_back(rule);
      }

      if (rule_family->rules.size() == 0) {
        // Rule families are at least a singleton of rules that can be trivially satisfied.
        Data::RuleInstance rule;
        rule.family = rule_family;
        rule_family->rules.push_back(rule);
      }

      program_rules.push_back(rule_family);
    }
  }

  if (program_rules.empty()) {
    std::cerr << "No program rules are available" << std::endl;
    return 1;
  }

  return 0;
}
