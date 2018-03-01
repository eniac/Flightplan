#!/bin/bash
set -euo pipefail
set -x
g++ -g -O0 -I. -I ../../../../RSEConfig -std=c++11 $(find .. -name '*.cpp') -o XilinxSwitch -D__USE_XOPEN2K8 -DHAVE_DECL_BASENAME=1

