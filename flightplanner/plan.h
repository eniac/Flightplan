/*
Flightplanner
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#ifndef FLIGHTPLAN_PLAN_H
#define FLIGHTPLAN_PLAN_H

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
#include "parsing.h"
#include "proof.h"

bool le_compare (std::vector<std::pair<Data::Bound, Obj>> ObjOrder, std::map<Data::Bound,double> m1, std::map<Data::Bound,double> m2);

struct Config {
  Data::G rules;
  Network *network = nullptr;
  Node *FS = nullptr;
  std::map<Data::Prop, std::vector<Point>> supporting_devices;
  std::map<std::string, Node*> alloc_node_seed; // based on FSAliases
  Point beginning;
  CFG_t CFG;
  std::string first_step() const {
    if (CFG.size() > 0) {
      return CFG.front().first;
    } else {
      assert(1 == FSAliases.size());
      assert(1 == program_rules.size());
      return FSAliases.front();
    }
  }
  // Next set of edges in the CFG
  CFG_t next_step(const std::string going_to) const;
};

struct Tip;
struct Solution;
class Planner {
 private:
  Solution* initialSolutionCandidate(); // Based on config->CFG create an initial Solution in solution_candidates with an initial Tip
  unsigned next_id = 0;
 public:
  unsigned getNextID() {
    return next_id++;
  }
  const Config *config = nullptr;
  Planner(Config *config) : config(config) {
    solution_candidates.push_back(initialSolutionCandidate());
  }
  enum class Outcome {Complete, OutOfCycles};
  static std::string StringOfOutcome (Outcome oc) {
    switch (oc) {
      case Outcome::Complete: return "Complete";
      case Outcome::OutOfCycles: return "OutOfCycles";
    }
  }
  Outcome plan(unsigned cycles_left);
  std::list<Solution*> solution_candidates;
  std::list<Solution*> solutions;
  static std::list<Solution*> orderSolutions(std::list<Solution*> solutions);

  static int findSolution(std::list<Solution*> solutions, std::set<std::string> latency, std::string cost, std::string power);
};

struct PossibleTarget {
  Point point;
  Link *link = nullptr;
};

struct Tip { // subsumes Step
  Link *link = nullptr; // how we got here
  Point here;
  static const std::string initial_entry_symbol;
  static const std::pair<std::string, std::string> initial_entry;
  static const std::string terminal_entry_item; // Used to detect a terminal tip.
  std::pair<std::string, std::string> entry; // Copy of CFG entry that explains how we got here. Is initial_entry for the first entry.
  Data::Prop goal; // Goal for the abstract program.
  std::map<Data::Bound,double> m; // State we observed at this point in the distributed program, before moving to the next step/tip.
  Solution *solution = nullptr;
  boost::optional<Data::Proof> proof;

  Tip* clone(Solution *new_solution) const {
    Tip *result = new Tip();
    result->link = this->link;
    result->here = this->here;
    result->entry = this->entry;
    result->goal = this->goal;
    result->m = this->m;
    result->solution = new_solution;
    result->proof = this->proof;
    return result;
  }

  void next(std::list<Solution*> *new_solution_candidates);
  std::vector<Tip*> try_Prop (Data::Prop prop, Link *link, Point point, std::pair<std::string, std::string> entry);
  void try_PossibleTargets(std::list<PossibleTarget> possible_targets, std::list<Solution*> *new_solution_candidates, Data::Prop goal, std::pair<std::string, std::string> entry);
  void targetConnectedDevices(std::list<PossibleTarget> &possible_targets);
  void targetConnectedDevice(Node *node, std::list<PossibleTarget> &possible_targets);

  bool isInitial() const {
    return (nullptr == this->link);
  }

  bool isTerminal() const {
    return (Tip::terminal_entry_item == this->entry.second);
  }

  std::string StringOfLinkEntry() const {
    std::string result;
    if (nullptr == this->link) {
      result += this->here.toString();
    } else {
      result += this->here.toString() + " (reached through " + this->link->toString() + ")";
    }
    return result;
  }
  std::string toShortString() const {
    return this->goal + " @ " + this->StringOfLinkEntry();
  }
  std::string toString(std::string prefix) const;
};

class Solution : public Data::SolutionState { // subsumes SimpleSolution
 private:
  Tip* initialTip(); // There's only ever one initial tip.

 public:
  ~Solution() {
    for (Tip *tip : this->tips) {
      delete tip;
    }

    for (Tip *tip : this->alloc_state) {
      delete tip;
    }
  }
  const unsigned id = 0;
  Planner *planner = nullptr;
  Solution (Planner *planner) : planner(planner), id(planner->getNextID()) {
    this->alloc_node = planner->config->alloc_node_seed;
    tips.insert(initialTip());
  }
  Solution* clone() const; // This is called when we need to explore alternative solutions
  // "tips" are the tips of search chains that haven't reached a final segment yet. (There should only be one final segment.)
  std::set<Tip*> tips; // If empty then this Solution is complete
  std::string toString(std::string prefix, bool coarsen = true) const {
    std::string result = prefix + "id=" + std::to_string(id);
    result += prefix + " |tips|=" + std::to_string(tips.size());
    result += prefix + "\n";
    result += prefix + "alloc_node:\n";
    for (std::pair<std::string, Node*> entry : alloc_node) {
      result += prefix + "  " + entry.first + ": " + entry.second->getName() + "\n";
    }
    result += prefix + "alloc_state:\n";
    for (Tip* tip : alloc_state) {
      //result += prefix + "  " + tip->toShortString() + "\n";
      result += tip->toString(prefix + "  ");
    }

    result += prefix + "Global State (Solution):" + "\n";
    for (std::pair<Data::Bound,double> entry : sol_m) {
      result += prefix + "  " + Data::BoundToString(entry.first) + ": " + std::to_string(entry.second) + "\n";
    }

    result += prefix + "Global State (Nodes):" + "\n";
    for (std::pair<Node*,std::map<Data::Bound,double>> node_state : node_m) {
      result += prefix + "  " + node_state.first->getName() + "\n";
      for (std::pair<Data::Bound,double> entry : node_state.second) {
        result += prefix + "    " + Data::BoundToString(entry.first) + ": " + std::to_string(entry.second) + "\n";
      }
    }

    result += prefix + "Global State (Links):" + "\n";
    for (std::pair<Link*,std::map<is_inverted,std::map<Data::Bound,double>>> link_state : link_m) {
      result += prefix + "  " + link_state.first->toString() + "\n";

      for (std::pair<is_inverted,std::map<Data::Bound,double>> directed_link_state : link_state.second) {
        if (directed_link_state.second.empty()) {
          continue;
        }

        std::string heading;
        if (directed_link_state.first) {
          heading = "(<=)";
        } else {
          heading = "(=>)";
        }

        //result += prefix + "  " + heading + "\n";
        for (std::pair<Data::Bound,double> entry : directed_link_state.second) {
          result += prefix + "    " + heading + " " + Data::BoundToString(entry.first) + ": " + std::to_string(entry.second) + "\n";
        }
      }
    }

    // Coarsening doesn't make sense if CFG is empty
    if (coarsen && 0 != this->planner->config->CFG.size()) {
      std::vector<std::pair<std::string,std::string>> coarsening = this->coarsen();
      if (coarsening.empty()) {
        result += prefix + "Coarsening: none\n";
      } else {
        result += prefix + "Coarsening:" + "\n";
        for (std::pair<std::string,std::string> entry : coarsening) {
          result += prefix + "  " + entry.first + " ~ " + entry.second + "\n";
        }
      }
    }

    return result;
  }

  // Show values of variables being optimised, for easy comparison.
  std::string toFocusedString(std::string prefix) const {
    std::string result;
    unsigned entries = 0;

    std::string result_tt;
    result_tt += prefix + "Terminal tips:\n";
    for (std::pair<Data::Bound, Obj> entry : ObjOrder) {
      for (Tip *tip : this->getTerminalTips()) {
        if (tip->m.find(entry.first) != tip->m.end()) {
          entries++;
          result_tt += prefix + "  @" + tip->here.node->getName() + " (" + tip->goal + "): " + entry.first + " = " + std::to_string(tip->m[entry.first]) + "\n";
        }
      }
    }
    if (entries > 0) {
      result += result_tt;
    }

    entries = 0;
    std::string result_ss;
    result_ss += prefix + "Solution state:\n";
    for (std::pair<Data::Bound, Obj> entry : ObjOrder) {
      if (this->sol_m.find(entry.first) != this->sol_m.end()) {
        entries++;
        result_ss += prefix + "  " + entry.first + " = " + std::to_string(this->sol_m.at(entry.first)) + "\n";
      }
    }
    if (entries > 0) {
      result += result_ss;
    }

    entries = 0;
    std::string result_ns;
    result_ns += prefix + "Node state:\n";
    for (std::pair<Node*,std::map<Data::Bound,double>> node_m_entry : this->node_m) {
      result_ns += prefix + "  " + node_m_entry.first->getName() + ":\n";
      for (std::pair<Data::Bound, Obj> entry : ObjOrder) {
        if (node_m_entry.second.find(entry.first) != node_m_entry.second.end()) {
          entries++;
          result_ns += prefix + "    " + entry.first + " = " + std::to_string(node_m_entry.second.at(entry.first)) + "\n";
        }
      }
    }
    if (entries > 0) {
      result += result_ns;
    }

    entries = 0;
    std::string result_ls;
    result_ls += prefix + "Link state:\n";
    for (std::pair<Link*,std::map<Data::SolutionState::is_inverted,std::map<Data::Bound,double>>> link_m_entry : this->link_m) {
      result_ls += prefix + "  " + link_m_entry.first->toString() + ":\n";
      for (std::pair<Data::SolutionState::is_inverted,std::map<Data::Bound,double>> directed_node_entry : link_m_entry.second) {
        for (std::pair<Data::Bound, Obj> entry : ObjOrder) {
          if (directed_node_entry.second.find(entry.first) != directed_node_entry.second.end()) {
            std::string direction;
            if (directed_node_entry.first) {
              direction = "(<=)";
            } else {
              direction = "(=>)";
            }

            entries++;
            result_ls += prefix + "    " + direction + " " + entry.first + " = " + std::to_string(directed_node_entry.second[entry.first]) + "\n";
          }
        }
      }
    }
    if (entries > 0) {
      result += result_ls;
    }

    return result;
  }

  // FIXME consts of field names
  std::string toCSVString() const {
    std::string result;

    double rate = this->getInitialTip()->m["Data::Bound::InputRate"];
    double latency = 0;
    double power = this->sol_m.at("Data::Bound::Power");
    double cost = this->sol_m.at("Data::Bound::Cost");
    double area = 0;

    for (Tip *tip : this->getTerminalTips()) {
        latency += tip->m["Data::Bound::Latency"];
    }

    std::list<std::string> area_fields = std::list<std::string>{
      "Data::Bound::FPGA1_Area_BRAMs",
      "Data::Bound::FPGA1_Area_FFs",
      "Data::Bound::FPGA1_Area_LUTs",

      "Data::Bound::FPGA2_Area_BRAMs",
      "Data::Bound::FPGA2_Area_FFs",
      "Data::Bound::FPGA2_Area_LUTs",

      "Data::Bound::FPGA3_Area_BRAMs",
      "Data::Bound::FPGA3_Area_FFs",
      "Data::Bound::FPGA3_Area_LUTs",

      "Data::Bound::FPGA4_Area_BRAMs",
      "Data::Bound::FPGA4_Area_FFs",
      "Data::Bound::FPGA4_Area_LUTs",

      "Data::Bound::FPGA5_Area_BRAMs",
      "Data::Bound::FPGA5_Area_FFs",
      "Data::Bound::FPGA5_Area_LUTs"};

    for (std::pair<Node*,std::map<Data::Bound,double>> node_m_entry : this->node_m) {
      for (std::string field : area_fields) {
        if (node_m_entry.second.find(field) != node_m_entry.second.end()) {
          area += node_m_entry.second.at(field);
        }
      }
    }

    return std::to_string(rate) + "," +
           std::to_string(latency) + "," +
           std::to_string(power) + "," +
           std::to_string(cost) + "," +
           std::to_string(area);
  }

  Tip* getInitialTip() const {
    return this->alloc_state[0];
  }

  std::vector<Tip*> getTerminalTips() const {
    std::vector<Tip*> result;

    for (Tip *tip : this->alloc_state) {
      if (tip->isTerminal()) {
        result.push_back(tip);
      }
    }

    return result;
  }

  bool isComplete() const {
    return tips.empty();
  }

  bool isSuccessful() const {
    for (std::pair<std::string, Node*> entry : this->alloc_node) {
      if (nullptr == entry.second) {
        return false;
      }
    }
    return true;
  }

  Tip* counterpart(Tip *tip) const {
    for (Tip *mytip : alloc_state) {
      if (tip->entry == mytip->entry) {
        return mytip;
      }
    }
    assert(false);
    return nullptr;
  }

  std::vector<std::pair<std::string,std::string>> coarsen() const {
    assert(this->isComplete());
    assert(this->isSuccessful());
    return coarsen(planner->config->first_step());
  }

  std::vector<std::pair<std::string,std::string>> coarsen(std::string seg_name) const {
    assert(this->isComplete());
    assert(this->isSuccessful());
    std::vector<std::pair<std::string,std::string>> result;

    CFG_t visiting = planner->config->next_step(seg_name);
    for (CFG_t::const_iterator it = visiting.begin(); it != visiting.end(); ++it) {
      std::string next_seg = (*it).second;
      if (alloc_node.at(seg_name) == alloc_node.at(next_seg)) {
        result.push_back(std::pair<std::string,std::string>(seg_name, next_seg));
      }

      for (CFG_t::const_iterator it2 = visiting.begin(); it2 != visiting.end(); ++it2) {
        std::string next_seg2 = (*it2).second;
        if (next_seg != next_seg2) {
          if (alloc_node.at(next_seg2) == alloc_node.at(next_seg)) {
            result.push_back(std::pair<std::string,std::string>(next_seg, next_seg2));
          }
        }
      }

      std::vector<std::pair<std::string,std::string>> sub_result = coarsen(next_seg);
      result.insert(result.end(), sub_result.begin(), sub_result.end());
    }

    return result;
  }
};

#endif // FLIGHTPLAN_PLAN_H
