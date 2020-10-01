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

#ifndef FLIGHTPLAN_TABLE_H
#define FLIGHTPLAN_TABLE_H

// FIXME since network.h doesn't use namespace. Needed these types declared.
struct Point;
class Node;
class Link;
struct Tip;

namespace Data {
using Bound = std::string;
using Prop = std::string;

std::string BoundToString (Bound type);

Bound StringToBound (std::string type);

std::string PropToString (Prop prop);

Prop StringToProp (std::string prop);

std::string PropsToString (const std::vector<Prop> props);

std::string PropsToString (const std::set<Prop> props);

std::string BoundUnits (Bound type);

using state = std::map<Bound,double>;
std::string StateString (const state m);

struct RelOp {
  double value (state m, Bound v) const {
    state::iterator it = m.find(v);
    if (it != m.end()) {
      return m[v];
    } else {
      throw std::runtime_error("Undefined bound '" + BoundToString(v) + "' in " + StateString(m));
    }
  }
  virtual bool f (state m, Bound v, double x) const = 0;
  virtual std::string toString (Bound v, double x) const = 0;
  virtual std::string toString (state m, Bound v, double x) const = 0;
};

struct LessRelVX : public RelOp {
  bool f (state m, Bound v, double x) const {
    // NOTE if |m|=0 then we get default value for m[v].. so we use this->value() to detect undefined bound values
    return (this->value(m, v) < x);
  }
  std::string toString (Bound v, double x) const {
    return (BoundToString(v) + "<" + std::to_string(x));
  }
  std::string toString (state m, Bound v, double x) const {
    return (std::to_string(this->value(m, v)) + "<" + std::to_string(x));
  }
};

struct LessRelXV : public RelOp {
  bool f (state m, Bound v, double x) const {
    return (x < this->value(m, v));
  }
  std::string toString (Bound v, double x) const {
    return (std::to_string(x) + "<" + BoundToString(v));
  }
  std::string toString (state m, Bound v, double x) const {
    return (std::to_string(x) + "<" + std::to_string(this->value(m, v)));
  }
};

struct GreatRelVX : public RelOp {
  bool f (state m, Bound v, double x) const {
    return (this->value(m, v) > x);
  }
  std::string toString (Bound v, double x) const {
    return (BoundToString(v) + ">" + std::to_string(x));
  }
  std::string toString (state m, Bound v, double x) const {
    return (std::to_string(this->value(m, v)) + ">" + std::to_string(x));
  }
};

struct GreatRelXV : public RelOp {
  bool f (state m, Bound v, double x) const {
    return (x > this->value(m, v));
  }
  std::string toString (Bound v, double x) const {
    return (std::to_string(x) + ">" + BoundToString(v));
  }
  std::string toString (state m, Bound v, double x) const {
    return (std::to_string(x) + ">" + std::to_string(this->value(m, v)));
  }
};

struct EqRelVX : public RelOp {
  bool f (state m, Bound v, double x) const {
    return (this->value(m, v) == x);
  }
  std::string toString (Bound v, double x) const {
    return (BoundToString(v) + "==" + std::to_string(x));
  }
  std::string toString (state m, Bound v, double x) const {
    return (std::to_string(this->value(m, v)) + "==" + std::to_string(x));
  }
};

struct BoundRel {
  static RelOp *lt_vx;
  static RelOp *lt_xv;
  static RelOp *gt_vx;
  static RelOp *gt_xv;
  static RelOp *eq_vx;
  Bound v;
  RelOp *op;
  double r;
  bool value (state m) const {
    return op->f(m, v, r);
  }
  std::string toString () const {
    return op->toString(v, r);
  }
  std::string toString (state m) const {
    return op->toString(m, v, r);
  }
  static struct BoundRel mk_EqVX(Bound v, double x) {
    BoundRel br;
    br.v = v;
    br.r = x;
    br.op = BoundRel::eq_vx;
    return br;
  }
  static struct BoundRel mk_LtVX(Bound v, double x) {
    BoundRel br;
    br.v = v;
    br.r = x;
    br.op = BoundRel::lt_vx;
    return br;
  }
  static struct BoundRel mk_LtXV(Bound v, double x) {
    BoundRel br;
    br.v = v;
    br.r = x;
    br.op = BoundRel::lt_xv;
    return br;
  }
  static struct BoundRel mk_GtVX(Bound v, double x) {
    BoundRel br;
    br.v = v;
    br.r = x;
    br.op = BoundRel::gt_vx;
    return br;
  }
  static struct BoundRel mk_GtXV(Bound v, double x) {
    BoundRel br;
    br.v = v;
    br.r = x;
    br.op = BoundRel::gt_xv;
    return br;
  }

  bool operator==(const BoundRel& other) const {
    return (this->v == other.v && this->op ==/*FIXME pointer equality*/ other.op && this->r == other.r);
  }

  static std::string toString (const std::vector<BoundRel> brels) {
    std::string result = " boundrels {";
    for (const BoundRel& brel : brels) {
      result += brel.toString() + " ";
    }
    return result + "}";
  }
};

struct SolutionState {
  using is_inverted = bool;
  std::map<std::string, Node*> alloc_node; // FIXME this might be redundant, can be derived from alloc_state?
  std::vector<Tip*> alloc_state; // The tip of the search graph as it progressed through the CFG.
  std::map<Link*,std::map<is_inverted,std::map<Data::Bound,double>>> link_m; // The "standing" resource usage (state) at a link. Inversion indicates whether the A->B ordering in the Link is inverted.
  std::map<Node*,std::map<Data::Bound,double>> node_m;
  std::map<Data::Bound,double> sol_m;
};

using gamma = std::function<state(state, Point*, SolutionState*)>;

gamma compose_gamma(std::list<gamma> gs);

struct RuleFamily;

struct RuleInstance {
  struct RuleFamily *family;
  unsigned index;
  std::vector<Prop> props;
  std::vector<BoundRel> bounds;
  gamma g;
  std::string toString (void) const;
};

struct RuleFamily {
  std::string name;
  Prop conclusion;
  // FIXME RuleInstance points to RuleFamily, but latter copies former -- should instead use vector of pointers to RuleInstance
  std::vector<RuleInstance> rules;
  std::string toString (void) const {
    std::string result;
    for (int idx = 0; idx < rules.size(); ++idx) {
      result += std::to_string(idx) + "=>" + rules[idx].toString();
    }
    return result;
  }
};

using G = std::vector<RuleFamily*>;

std::string RulesToString (G rules);

template <typename T>
bool contains (std::set<T> set, T elem) {
  typename std::set<T>::iterator it = set.find(elem);
  if (it == set.end()) {
    return false;
  }
  return true;
}

template <typename T>
bool contains (std::vector<T> vector, T elem) {
  for (T& elem2 : vector) {
    if (elem == elem2) {
      return true;
    }
  }
  return false;
}

template <typename T>
bool included (std::set<T> s1, std::set<T> s2) {
  bool all_included = true;
  for (const T& elem : s1) {
    typename std::set<T>::iterator it = s2.find(elem);
    if (it == s2.end()) {
      all_included = false;
      break;
    }
  }
  return all_included;
}

template <typename T>
bool included (std::vector<T> s1, std::vector<T> s2) {
  bool all_included = true;
  for (const T& elem : s1) {
    bool found = false;
    for (const T& elem_s2 : s2) {
      if (elem.toString() == elem_s2.toString()) {
        found = true;
        break;
      }
    }
    if (!found) {
      all_included = false;
      break;
    }
  }
  return all_included;
}

// FIXME define ProofFamily counterpart of RuleFamily --
// include ector of Proof corresponding to each RuleInstance.
//  Need total ordering over resulting states, for each proof,
//  to pick the most "expensive".
class Proof {
  private:
    Proof(){};

    Prop conjecture;
    bool is_conjecture = false;

    Prop prop;
    bool is_assumed = false;
    // FIXME link to evidence (Node or Point) in which the prop is assumed.

    RuleInstance r;
    std::vector<boost::optional<Proof>> subproofs;

  public:
  Proof(Prop conjecture) : conjecture(conjecture) {is_conjecture = true;}

  static Proof Assumed(Prop prop) {
    Proof p;
    p.is_assumed = true;
    p.prop = prop;
    return p;
  }

  Proof(RuleInstance r, std::vector<boost::optional<Proof>> subproofs) : r(r), subproofs(subproofs) {
    assert(r.props.size() == subproofs.size());
  }
  bool proof_is_conjecture() {
    return is_conjecture;
  }

  Prop concludes (void) { // FIXME add method that returns set of all intermediate conclusions along the way; could be used to produce "props" parameter to prove()
    if (is_assumed) {
      return prop;
    } else if (is_conjecture) {
      return conjecture;
    } else {
      return r.family->conclusion;
    }
  }
  std::string toString(void) const {
    if (is_assumed) {
      return "(Assumed)" + PropToString(prop);
    }

    assert(r.props.size() == subproofs.size());
    std::vector<Prop>::const_iterator props_it;
    std::vector<boost::optional<Proof>>::const_iterator subproofs_it;
    std::string result = PropToString(r.family->conclusion) + " <-(" + r.family->name + ")-{";
    for (props_it = r.props.begin(), subproofs_it = subproofs.begin();
         props_it != r.props.end() && subproofs_it != subproofs.end();
         ++props_it, ++subproofs_it) {
      if (*subproofs_it == boost::none) {
        result += "[" + PropToString(*props_it) + "] ";
      } else {
        result += ((*subproofs_it).get()).toString() + " ";
      }
    }
    result += "}";
    return result;
  }

  // FIXME instead of passing "bounds", pass the \mu function that'll be used to evaluate the bounds of rules.   
  bool check (std::vector<Prop> props, std::vector<BoundRel> bounds) {
    for (BoundRel& bound : r.bounds) {
      if (!contains<BoundRel>(bounds, bound)) {
        return false;
      }
    }

    std::vector<Prop>::iterator props_it;
    std::vector<boost::optional<Proof>>::iterator subproofs_it;

    for (props_it = r.props.begin(), subproofs_it = subproofs.begin();
         props_it != r.props.end() && subproofs_it != subproofs.end();
         ++props_it, ++subproofs_it) {
      if (*subproofs_it == boost::none) {
        if (!contains<Prop>(props, *props_it)) {
          return false;
        }
      } else {
        if (r.family->conclusion != *props_it) {
          return false;
        }
        if (! (*subproofs_it).get().check(props, bounds)) {
          return false;
        }
      }
    }
    return true;
  }
  gamma stateTransform(void) const {
    if (is_assumed || subproofs.empty()) {
      return [](Data::state m, Point *point, SolutionState* state) -> Data::state {return m;};
    }

    std::list<gamma> gammas;
    for (const boost::optional<Proof>& subproof : subproofs) {
      if (subproof != boost::none) {
        gammas.push_back((*subproof).stateTransform());
      }
    }
    gammas.push_back(r.g);
    return compose_gamma(gammas);
  }
  static gamma stateTransform(const std::vector<Data::Proof> proofs) {
    std::list<gamma> gammas;
    for (const Data::Proof proof : proofs) {
      gammas.push_back(proof.stateTransform());
    }
    return compose_gamma(gammas);
  }

  std::vector<RuleInstance> rulesUsed (void) const {
    if (is_assumed) {
      return {};
    }

    std::vector<RuleInstance> result = {r};
    for (boost::optional<Proof> subproof : subproofs) {
      if (subproof != boost::none) {
        for (RuleInstance &rule : (*subproof).rulesUsed()) {
          result.push_back(rule);
        }
      }
    }
    return result;
  }

  std::string rulesUsedString (void) const {
    std::string result = "rules: \n";
    if (is_assumed) {
      return result + "  (assumed)\n";
    }
    for (const RuleInstance &rule : this->rulesUsed()) {
      result += "  " + rule.toString() + "\n";
    }
    return result;
  }
};

} // namespace Data

void increment_FPGA_usage (double LUTs, double BRAMs, double FFs, Data::state &state, Point *point, Data::SolutionState* solstate);

#endif // FLIGHTPLAN_TABLE_H
