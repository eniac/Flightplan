/*
Flightplanner
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#include "proof.h"

namespace Data {

std::vector<Proof> prove (size_t depth, Prop p, G rules, const Point point, const Data::state m, bool trace, pcache &pc) {
  if (trace) {
    std::cout << "Prove " << PropToString(p) << " depth=" << std::to_string(depth) << " point=" << point.toString() << " assumed_props=" << PropsToString(point.node->getProps()) << " required_bounds=" << BoundRel::toString(point.node->getBounds()) << " " <<  StateString(m) << std::endl;
  }

  if (depth > max_proof_depth) {
    return std::vector<Proof>();
  }

  const std::vector<Data::BoundRel> required_bounds = point.node->getBounds();
  const std::set<Data::Prop> assumed_props = point.node->getProps();

  for (const BoundRel& bound : required_bounds) {
    if (!bound.value(m)) {
      return std::vector<Proof>();
    }
  }

  // Check if (contains<Prop>(assumed_props, p)), in which case use an implicit rule for P-->P.
  if (contains<Prop>(assumed_props, p)) {
    return std::vector<Proof>{Proof::Assumed(p)};
  }

  std::vector<Proof> result;

  for (RuleFamily *rule_family : rules) {

    bool skip_this_rule_family = false;
    for (std::string excluded_rule : exclude_rules) {
      if (rule_family->name == excluded_rule) {
        skip_this_rule_family = true;
        break;
      }
    }

    if (skip_this_rule_family) {
      continue;
    }

    if (rule_family->conclusion == p) {
      // FIXME heuristically using the rule with most prop dependencies,
      //       assuming it to be the most "expensive",
      //       but for completeness should show that all rules in the family
      //       can be used successfully..
      assert(rule_family->rules.size() > 0);
      int num_props = 0;
      RuleInstance *rule = nullptr;
      for (RuleInstance &ri : rule_family->rules) {
        if (ri.props.size() > num_props || nullptr == rule) {
          rule = &ri;
          num_props = ri.props.size();
        }
      }
      assert(nullptr != rule);

      if (trace) {
        std::cout << "trying: " << rule->toString() << std::endl;
      }

      bool re_loop = false;
      for (BoundRel& bound : rule->bounds) {
        if (!bound.value(m)) {
          re_loop = true;
          break;
        }
      }

      if (re_loop) {
        continue;
      }

      std::vector<std::vector<boost::optional<Proof>>> hyps_alternatives;
      hyps_alternatives.push_back(std::vector<boost::optional<Proof>>()); // Seed one empty element to begin with.
      re_loop = false;
      for (Prop& sub : rule->props) {

        if (contains<Prop>(assumed_props, sub)) {
          for (std::vector<boost::optional<Proof>> &hyps : hyps_alternatives) {
            hyps.push_back(boost::none);
          }
        } else {
          std::vector<Proof> sub_proofs;
          if (pc.find(sub) == pc.end()) {
            sub_proofs = prove(depth + 1, sub, rules, point, m, trace, pc);
          } else {
            sub_proofs = pc[sub];
            assert(!sub_proofs.empty());
          }

          if (sub_proofs.empty()) {
            re_loop = true;
            break;
          } else {
            if (pc.find(sub) == pc.end()) {
              pc[sub] = sub_proofs;
            }

            // "Multiply-out" the proofs we get.
            std::vector<std::vector<boost::optional<Proof> > > new_hyps_alternatives;
            for (Proof sub_proof : sub_proofs) {
              for (std::vector<boost::optional<Proof> > hyps : hyps_alternatives) {
                hyps.push_back(sub_proof);
                new_hyps_alternatives.push_back(hyps);
                if (new_hyps_alternatives.size() > max_proof_alternatives) {
                  break;
                }
              }
            }

            hyps_alternatives = new_hyps_alternatives;
          }
        }
      }

      if (re_loop) {
        continue;
      }

      for (std::vector<boost::optional<Proof> > &hyps : hyps_alternatives) {
        result.push_back(Proof(*rule, hyps));
      }
    }
  }

  if (result.empty() && trace) {
    std::cout << "Could not prove" << std::endl;
  }

  return result;
}

}
