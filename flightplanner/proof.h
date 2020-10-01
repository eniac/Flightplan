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
