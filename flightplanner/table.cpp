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
#include "parsing.h"

namespace Data {

std::string BoundToString (Bound type)
{
  return type;
}

Bound StringToBound (std::string type)
{
  return type;
}

std::string PropToString (Prop prop)
{
  return prop;
}

Prop StringToProp (std::string prop)
{
  return prop;
}

std::string PropsToString (const std::vector<Prop> props)
{
  std::string result = "props {";
  for (const Prop& prop : props) {
    result += PropToString(prop) + " ";
  }
  return result + "}";
}

std::string PropsToString (const std::set<Prop> props)
{
  std::string result = "props {";
  for (const Prop& prop : props) {
    result += PropToString(prop) + " ";
  }
  return result + "}";
}

std::string BoundUnits (Bound type)
{
  assert(units_of_measurement.find(type) != units_of_measurement.end());
  return units_of_measurement[type];
}

std::string StateString (const state m)
{
  std::string result = "state {\n";
  for (const std::pair<Bound, double>& pair : m) {
    result += BoundToString(pair.first) + " = " + std::to_string(pair.second) + " " + BoundUnits(pair.first) + "\n";
  }
  return result + "}\n";
}

RelOp *BoundRel::eq_vx = new EqRelVX();
RelOp *BoundRel::lt_vx = new LessRelVX();
RelOp *BoundRel::lt_xv = new LessRelXV();
RelOp *BoundRel::gt_vx = new GreatRelVX();
RelOp *BoundRel::gt_xv = new GreatRelXV();

gamma compose_gamma(std::list<gamma> gs) {
  if (gs.size() == 0) {
      throw std::runtime_error("Cannot compose empty gammas");
  }

  gamma g1 = gs.front();
  gs.pop_front();
  if (gs.empty()) {
    return g1;
  } else {
    return [g1, gs](state m, Point *point, SolutionState* solstate) -> state {return g1(compose_gamma(gs)(m, point, solstate), point, solstate);};
  }
}

std::string RulesToString (G rules)
{
  std::string result;
  for (const RuleFamily *rule_family : rules) {
    result += rule_family->toString() + "\n";
  }
  return result;
}

std::string RuleInstance::toString (void) const {
  std::vector<std::string> hyps;
  for (const Prop &prop : props) {
    hyps.push_back(PropToString(prop));
  }
  for (const BoundRel &br : bounds) {
    hyps.push_back(br.toString());
  }
  std::string hyps_s = std::accumulate(hyps.begin(), hyps.end(), std::string(),
      [](const std::string& acc, const std::string& str) -> std::string {
        return acc + (acc.length() > 0 ? ", " : "") + str;
        });
  return "\"" + family->name + "\": {" + hyps_s + "} --> " + PropToString(family->conclusion);
}

} // namespace Data

// FIXME we don't track usage of SRAM on the Tofino.
void increment_FPGA_usage (double LUTs, double BRAMs, double FFs, Data::state &state, Point *point, Data::SolutionState *solstate) {
  std::string node_name = point->node->getName();
  std::string luts_var_name = alloctable_fpga[node_name][FPGAMeasure::LUTs];
  std::string brams_var_name = alloctable_fpga[node_name][FPGAMeasure::BRAMs];
  std::string ffs_var_name = alloctable_fpga[node_name][FPGAMeasure::FFs];

  solstate->node_m[point->node][luts_var_name] = solstate->node_m[point->node][luts_var_name] + LUTs;
  solstate->node_m[point->node][brams_var_name] = solstate->node_m[point->node][brams_var_name] + BRAMs;
  solstate->node_m[point->node][ffs_var_name] = solstate->node_m[point->node][ffs_var_name] + FFs;
}
