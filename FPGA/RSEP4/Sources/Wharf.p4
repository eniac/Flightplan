/*
Top-level P4 for Wharf
DCOMP project, UPenn, April 2018
*/

#include "Encoder.p4"

XilinxSwitch(Parser(), Update(), Deparser()) main;

