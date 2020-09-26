/*
Flightplanner
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#include "plan.h"

// Less than or equal to.
// Less is better -- closer to the optimal
bool le_compare (std::vector<std::pair<Data::Bound, Obj>> ObjOrder, std::map<Data::Bound,double> m1, std::map<Data::Bound,double> m2) {
  bool result = true;
  for (std::pair<Data::Bound, Obj> obj : ObjOrder) {
    if (Obj::Min == obj.second) {
      if (m1[obj.first] > m2[obj.first]) {
        result = false;
        break;
      }
    } else if (Obj::Max == obj.second) {
      if (m1[obj.first] < m2[obj.first]) {
        result = false;
        break;
      }
    } else {
      assert(false);
    }
  }

  return result;
}

bool le_compare (std::vector<std::pair<Data::Bound, Obj>> ObjOrder, Solution *solution1, Solution *solution2) {
  bool le = true;

  std::vector<Tip*> tips1 = solution1->getTerminalTips();
  std::vector<Tip*> tips2 = solution2->getTerminalTips();
  assert(tips1.size() == tips2.size());

  for (int i = 0; i < tips1.size(); ++i) {
    le &= le_compare(ObjOrder, tips1[i]->m, tips2[i]->m);

    if (!le) {
      break;
    }
  }

  if (le) {
    le &= le_compare(ObjOrder, solution1->sol_m, solution2->sol_m);
  }

  return le;
}

std::list<Solution*> Planner::orderSolutions(std::list<Solution*> solutions) {
  std::list<Solution*> result;
  for (Solution *solution : solutions) {
    if (result.empty()) {
      result.push_back(solution);
      continue;
    }

    bool le = true;
    for (std::list<Solution*>::iterator it = result.begin(); it != result.end(); ++it) {
      le = le_compare(ObjOrder, solution, *it);

      if (le) {
        result.emplace(it, solution);
        break;
      }
    }

    if (le) {
      continue;
    }

    result.push_back(solution);
  }

  if (invert_order) {
    result.reverse();
  }

  return result;
}

// FIXME earlier version of this system provided information about failed proofs for debugging,
//       e.g., whether it was due to bounds checks, propositions, etc.
std::vector<Tip*> Tip::try_Prop (Data::Prop prop, Link *link, Point point, std::pair<std::string, std::string> entry)
{
    std::vector<Tip*> result;

    // NOTE on relation between "point" and "this->here": this->here is where
    //      the tip originated, and point may be on a different device,
    //      reachable through link, where we are trying to prove prop.
    if (nullptr != link) {
      // "point" must be connected by "link" to tip->here.
      assert((this->here.node == link->getA().node && point.node == link->getB().node) ||
          (this->here.node == link->getB().node && point.node == link->getA().node));
    }

    std::vector<Data::Proof> proofs;

    bool can_proceed = true;

    std::map<Data::Bound,double> m_link = this->m;
    bool is_inverted;
    if (nullptr != link) {
      is_inverted = (this->here.node == link->getB().node);
      for (std::pair<Data::Bound,double> entry : solution->link_m[link][is_inverted]) {
        m_link[entry.first] += entry.second;
      }
    }

    for (const Data::BoundRel& bound : point.bounds) {
      if (!bound.value(m_link)) {

        if (veryverbose) {
          std::cout << "    Cannot proceed at point " << point.toString() << " bound " << bound.toString() << std::endl;
        }

        can_proceed = false;
        break;
      }
    }

    for (const Data::BoundRel& bound : point.node->getBounds()) {
      if (!bound.value(m_link)) {
        if (veryverbose) {
          std::cout << "    Cannot proceed at point node " << point.node->toString() << " bound " << bound.toString() << std::endl;
        }

        can_proceed = false;
        break;
      }

      // FIXME this might be confusing -- have node-level constraints being checked by solution-level state,
      //       it's allowed but there might be a cleaner separation between types of constraints.
      if (!bound.value(solution->sol_m)) {
        if (veryverbose) {
          // FIXME improve output message  
          std::cout << "    SOLUTION Cannot proceed at point node " << point.node->toString() << " bound " << bound.toString() << std::endl;
        }

        can_proceed = false;
        break;
      }

      if (!bound.value(solution->node_m[point.node])) {
        if (veryverbose) {
          // FIXME improve output message  
          std::cout << "    NODE_M Cannot proceed at point node " << point.node->toString() << " bound " << bound.toString() << std::endl;
        }

        can_proceed = false;
        break;
      }
    }

    // FIXME hack to limit number of allocations to each device.
    //       this can be expressed more neatly through the rules.
    if (single_allocation &&
        can_proceed &&
        // We allow the FS to be allocated-to more than once.
        point.node != solution->planner->config->FS) {
      for (std::pair<std::string, Node*> allocation : solution->alloc_node) {
        assert(nullptr != point.node);
        // Check that we haven't already allocated to this device.
        if (allocation.second != nullptr && allocation.second == point.node) {
          if (veryverbose) {
            std::cout << "    Cannot proceed at point node " << point.node->toString() << " since already allocated" << std::endl;
          }

          can_proceed = false;
          break;
        }
      }
    }

    for (std::string excluded_device : exclude_devices) {
      if (point.node->getName() == excluded_device) {
        if (veryverbose) {
          std::cout << "    Cannot proceed at point node " << point.node->toString() << " since is excluded" << std::endl;
        }

        can_proceed = false;
        break;
      }
    }

    if (can_proceed) {
      if (veryverbose) {
        std::cout << "    Trying to prove " << prop << " at " << point.toString() << std::endl;
      }
      Data::pcache pc;
      proofs = prove(0, prop, solution->planner->config->rules, point, this->m, trace_proof, pc);
    }

    if (can_proceed && !proofs.empty()) {
      if (nullptr != link) {
        // Update solution-wide state
        // Do this before we clone tip->solution, so all the clones will inherit the updated state.
        for (Data::Bound bound : link_bound_accumulate) {
          solution->link_m[link][is_inverted][bound] = m_link[bound];
        }
      }

      for (Data::Proof proof : proofs) {
        Solution *new_solution = this->solution->clone();

        Tip *tip = new Tip();
        tip->here = point;
        tip->entry = entry;
        tip->goal = prop;
        tip->proof = proof;
        tip->solution = new_solution;
        tip->m = proof.stateTransform()(this->m, &point, new_solution);

        assert((new_solution->alloc_node.find(prop) == new_solution->alloc_node.end()) ||
            (new_solution->alloc_node[prop] == point.node));
        new_solution->alloc_node[prop] = point.node;
        assert(nullptr != tip);
        new_solution->alloc_state.push_back(tip);

        new_solution->tips.insert(tip);

        // We've prepared everything so this solution candidate can be followed up when we return the std::vector<Tip*>.
        result.push_back(tip);
      }
    }

    return result;
}

const std::string Tip::initial_entry_symbol = "+";
const std::pair<std::string, std::string> Tip::initial_entry = std::pair<std::string, std::string>(Tip::initial_entry_symbol, Tip::initial_entry_symbol);
const std::string Tip::terminal_entry_item = "(terminal)";

void Tip::try_PossibleTargets(std::list<PossibleTarget> possible_targets, std::list<Solution*> *new_solution_candidates, Data::Prop goal, std::pair<std::string, std::string> entry)
{
  if (veryverbose) {
    std::cout << "|possible_targets|=" << std::to_string(possible_targets.size()) << std::endl;
  }

  for (PossibleTarget pt : possible_targets) {
    if (veryverbose) {
      std::cout << "  target:" << pt.point.node->getName() << std::endl;
    }

    std::vector<Tip*> options = this->try_Prop(goal, pt.link, pt.point, entry);
    if (veryverbose) {
      std::cout << "    options (proofs): " << std::to_string(options.size()) << std::endl;
      std::cout << "      solution ids: ";
    }

    for (Tip *tip : options) {
      tip->link = pt.link;
      new_solution_candidates->push_back(tip->solution); // NOTE tip's solution has already been cloned from this->solution by Tip::try_Prop(). And alloc_state and alloc_node for that solution were updated there too.
      if (veryverbose) {
        std::cout << std::to_string(tip->solution->id) << " ";
      }
    }
    if (veryverbose) {
      std::cout << std::endl;
    }
  }
}

void Tip::targetConnectedDevice(Node *node, std::list<PossibleTarget> &possible_targets) {
  std::set<Link*> links = this->solution->planner->config->network->getLinksUndirected(this->here.node, node);

  for (Link *link : links) {
    PossibleTarget pt;
    if (link->getA().node == this->here.node) {
      pt.point = link->getB();
    } else {
      pt.point = link->getA();
    }
    pt.link = link;
    possible_targets.push_back(pt);
  }
}

void Tip::targetConnectedDevices(std::list<PossibleTarget> &possible_targets)
{
  // Look for alternatives for where to execute the segment among connected devices
  // FIXME not using this info, which could make analysis more precise:
  //       - std::set<Data::Prop> &supporting_device_classes
  //       - excluded_port
  for (std::pair<Data::Prop, std::vector<Point>> device_class : this->solution->planner->config->supporting_devices) {
    //std::set<Link*> links = this->solution->planner->config->network->getLinksUndirected(this->here.node, device_class.second[0/*FIXME ignoring others*/].node);

    for (Point device_point : device_class.second) {
      targetConnectedDevice(device_point.node, possible_targets);
    }
  }
}

CFG_t Config::next_step(const std::string going_to) const {
  CFG_t result;

  if (0 == CFG.size()) {
     assert(1 == FSAliases.size());
     assert(1 == program_rules.size());
     // NOTE this "next_step()" invocation will always return the same result; it's implicitly also the final step in the plan given that CFG is empty.
     result.push_back(std::pair<std::string,std::string>(FSAliases.front(), Tip::initial_entry_symbol));
  } else {
    for (std::pair<std::string,std::string> entry : CFG) {
      if (going_to == entry.first) {
        result.push_back(entry);
      }
    }
  }

  return result;
}

/*
consult CFG to find set of next entries
for each of these:
  find a set of target options where to try_Prop -- for this need to consult Config (for topology etc).
    for each "additional" option, clone the solution and treat the cloned solution as the "current" one's parent solution.
  add each the new tip to its solution->tips
  add the parent solution(s) to new_solution_candidates

a tip is the next step we need to prove
  it says that we have reached the LHS of the relation, and are attempting to reach the RHS from it
    and to further prove that the RHS is not ony reachable by the graph, but that we can get a proof from it.
    at which point we'll continue exploring the relation further
      (or terminate this chain if the RHS does not lead anywhere)
*/
void Tip::next(std::list<Solution*> *new_solution_candidates) {
  this->solution->tips.erase(this);

  if (veryverbose) {
    std::cout << "@soln:" << std::to_string(this->solution->id) << " @" << this->here.node->getName() << " : " << this->entry.first << " --> " << this->entry.second << std::endl;   
  }

  CFG_t next_steps;
  if (Tip::initial_entry == this->entry) {
    next_steps = this->solution->planner->config->next_step(this->solution->planner->config->first_step());
    if (veryverbose) {
      std::cout << "|next_steps|=" << std::to_string(next_steps.size()) << std::endl;
    }

    Solution *new_solution = nullptr;
    for (std::pair<std::string, std::string> next_entry : next_steps) {
      if (veryverbose) {
        std::cout << "(initial) entry: " << next_entry.first << " --> " << next_entry.second << std::endl;
      }
      assert(solution->alloc_node.find(next_entry.first) != solution->alloc_node.end());
      assert(solution->alloc_node[next_entry.first] == solution->planner->config->FS);
      if (veryverbose) {
        std::cout << "(initial) processing: " << next_entry.first << " @" << this->here.node->getName() << std::endl;
      }

      std::vector<Tip*> options = this->try_Prop(next_entry.first, nullptr, this->here, next_entry);
      if (veryverbose) {
        std::cout << "(initial)  options (proofs): " << std::to_string(options.size()) << std::endl;
      }

      for (Tip *tip : options) {
        if (nullptr == new_solution) {
          new_solution = tip->solution;
        } else {
          //Merge solutions:
          //  ensure have complementary solution so far
          //  add tips to tips set
          //  update all tips' solution to point to the new one -- clone a new tip. FIXME delete old solution so we won't memory leak?
          Tip *new_tip = tip->clone(new_solution);
          new_solution->tips.insert(new_tip);
        }
      }
    }

    if (0 == this->solution->planner->config->CFG.size()) {
      // No further tips to pursue for this solution if CFG is empty.
      new_solution->tips.clear();
    }

    new_solution_candidates->push_back(new_solution);

    return;
  } else {
    // If CFG is empty, then there are no next steps to attempt in the plan.
    if (0 != this->solution->planner->config->CFG.size()) {
      next_steps = this->solution->planner->config->next_step(this->entry.second);
    }
  }

  if (veryverbose) {
    std::cout << "|next_steps|=" << std::to_string(next_steps.size()) << std::endl;
  }

  if (next_steps.empty()) {
    if (Tip::terminal_entry_item == this->entry.second) {
      if (veryverbose) {
        std::cout << "  terminated!" << std::endl;
      }

      new_solution_candidates->push_back(this->solution);
      return;
    }

    next_steps.push_back(std::pair<std::string, std::string>(this->entry.second, Tip::terminal_entry_item));
  }

  for (std::pair<std::string, std::string> entry : next_steps) {
    if (veryverbose) {
      std::cout << "entry: " << entry.first << " --> " << entry.second << std::endl;
      std::cout << "  processing: " << entry.first << " @" << this->here.node->getName() << std::endl;
    }

    if (solution->alloc_node.find(entry.first) == solution->alloc_node.end()) {
      if (veryverbose) {
        std::cout << "  (new node allocation)" << std::endl;
      }

      std::list<PossibleTarget> possible_targets;
      PossibleTarget pt;
      // Attempt to execute this segment here
      pt.point = this->here;
      pt.link = nullptr;
      possible_targets.push_back(pt);

      // Enumerate all ways of satisfying the constraints for entry.first
        // Check "here"
        // If FS, also check everything connected to here (if it's a supporting device that's not disabled for offload)
      // For each satisfying assignment, create a solution (or pick the best one if in greedy mode)

      if (this->here.node == this->solution->planner->config->FS) {
        this->targetConnectedDevices(possible_targets);
      }

      this->try_PossibleTargets(possible_targets, new_solution_candidates, entry.first, entry);
    } else {
      if (veryverbose) {
        std::cout << "  (existing node allocation)" << std::endl;
      }
      // Is it the current node?
      // Enumerate all links to that node
      // For each way of reaching it, create a solution (or pick the best one if in greedy mode)

      if (solution->alloc_node[entry.first] == this->here.node) {
        if (veryverbose) {
          std::cout << "  (already at the right place)" << std::endl;
        }

        std::list<PossibleTarget> possible_targets;
        PossibleTarget pt;
        // Attempt to execute this segment here
        pt.point = this->here;
        pt.link = nullptr;
        possible_targets.push_back(pt);

        this->try_PossibleTargets(possible_targets, new_solution_candidates, entry.first, entry);
      } else {
        if (veryverbose) {
          std::cout << "  (need to move from " << this->here.node->getName() << " to " <<
            solution->alloc_node[entry.first]->getName() << ")" << std::endl;
        }

        std::list<PossibleTarget> possible_targets;
        this->targetConnectedDevice(solution->alloc_node[entry.first], possible_targets);

        this->try_PossibleTargets(possible_targets, new_solution_candidates, entry.first, entry);
      }
    }
  }
}

Solution* Solution::clone() const {
  Solution *result = new Solution(this->planner);
  result->tips.clear();
  std::map<const Tip*,Tip*> tip_mapping;
  for (const Tip *tip : this->tips) {
    assert(tip_mapping.find(tip) == tip_mapping.end());
    Tip *new_tip = tip->clone(result);
    result->tips.insert(new_tip);
    tip_mapping[tip] = new_tip;
  }
  result->alloc_node = this->alloc_node;

  for (const Tip *tip : this->alloc_state) {
    assert(nullptr != tip);
    if (tip_mapping.find(tip) == tip_mapping.end()) {
      Tip *new_tip = tip->clone(result);
      tip_mapping[tip] = new_tip;
    }
    result->alloc_state.push_back(tip_mapping[tip]);
  }

  result->sol_m = this->sol_m;
  result->link_m = this->link_m;
  result->node_m = this->node_m;

  return result;
}

Solution* Planner::initialSolutionCandidate() {
  return new Solution(this);
}

Tip* Solution::initialTip() {
  Tip *tip = new Tip();
  tip->here = planner->config->beginning;
  tip->entry = Tip::initial_entry;
  tip->goal = planner->config->first_step();
  tip->m = /*FIXME planner->config->*/initial_m;
  tip->solution = this;
  return tip;
}

Planner::Outcome Planner::plan(unsigned cycles_left) {
  std::list<Solution*> new_solution_candidates;
  while (!solution_candidates.empty() && cycles_left > 0) {
    if (veryverbose) {
      std::cout << "plan: cycles_left=" << std::to_string(cycles_left) << std::endl;
    }
    cycles_left -= 1;
    if (veryverbose) {
      std::cout << "plan: solution_candidates.size()=" << std::to_string(solution_candidates.size()) << std::endl;
    }
    for (Solution* solution : solution_candidates) {
      if (solution->isComplete()) {
        if (solution->isSuccessful()) {
          solutions.push_back(solution);
        }
      } else {
        std::set<Tip*> solution_tips = solution->tips;
        if (veryverbose) {
          std::cout << "plan: solution_tips.size()=" << std::to_string(solution_tips.size()) << std::endl;
        }
        for (Tip *tip : solution_tips) {
          tip->next(&new_solution_candidates);
          break; // FIXME this is implemented crudely -- the plan is to continue refining this solution later.
        }
      }
    }

    if (veryverbose) {
      std::cout << "plan: new_solution_candidates.size()=" << std::to_string(new_solution_candidates.size()) << std::endl;
    }

    // FIXME naive, wasteful code.
    for (Solution *solution : solution_candidates) {
      bool found = false;
      for (Solution *other_solution : new_solution_candidates) {
        if (solution == other_solution) {
          found = true;
          break;
        }
      }
      for (Solution *other_solution : solutions) {
        if (solution == other_solution) {
          found = true;
          break;
        }
      }
      if (!found) {
//        delete solution; FIXME improve the check for redundant solutions
      }
    }

    if (!new_solution_candidates.empty() && greedy_search) {
      std::list<Solution*> sorted_candidates = Planner::orderSolutions(new_solution_candidates);
      new_solution_candidates = std::list<Solution*>{sorted_candidates.front()};
    }

    solution_candidates = new_solution_candidates;
    new_solution_candidates.clear();
  }
  if (cycles_left > 0) {
    return Outcome::Complete;
  } else {
    return Outcome::OutOfCycles;
  }
}

std::string Tip::toString(std::string prefix) const {
  std::string result;
  result += prefix + "tip for entry: (soln." + std::to_string(this->solution->id) + ") " + this->entry.first + " --> " + this->entry.second + "\n";
  result += prefix + "  proves " + this->toShortString() + "\n";
  result += prefix + "    " + (*this->proof).toString() + "\n";

  result += prefix + "  State:" + "\n";
  for (std::pair<Data::Bound,double> entry : this->m) {
    result += prefix + "    " + Data::BoundToString(entry.first) + ": " + std::to_string(entry.second) + "\n";
  }
  return result;
}

//search function to find the index of a solution having particular values, for comparing greedy vs optimal
int Planner::findSolution(std::list<Solution*> solutions, std::set<std::string> latency, std::string cost, std::string power) {
  int i = -1;
  for (Solution *solution : solutions) {
    i++;
    bool all_bounds_met = true;
    for (Tip *tip : solution->getTerminalTips()) {

      if ((tip->m.find("Data::Bound::Latency") != tip->m.end()) &&
        (latency.find(std::to_string(tip->m.at("Data::Bound::Latency"))) == latency.end())) {
         all_bounds_met = false;
         break;
      }
    }

    if (!all_bounds_met) {
      continue;
    }

    if ((solution->sol_m.find("Data::Bound::Cost") != solution->sol_m.end()) &&
      (std::to_string(solution->sol_m.at("Data::Bound::Cost")) != cost)) {
      continue;
    }

    if ((solution->sol_m.find("Data::Bound::Power") != solution->sol_m.end()) &&
      (std::to_string(solution->sol_m.at("Data::Bound::Power")) != power)) {
      continue;
    }

    return i;
  }

  return -1;
}
