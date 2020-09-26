/*
Flightplanner
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#ifndef FLIGHTPLAN_PROOF_H
#define FLIGHTPLAN_PROOF_H

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

#include "table.h"
#include "network.h"
#include "parsing.h"

namespace Data {

// Proof's depth needs bounding since could have recursive rules
const size_t max_proof_depth = 15;
const size_t max_proof_alternatives = 50;

using pcache = std::map<Prop, std::vector<Proof>>;

std::vector<Proof> prove (size_t depth, Prop p, G rules, const Point point, const Data::state m, bool trace, pcache &pc);

} // namespace Data
#endif // FLIGHTPLAN_PROOF_H
