#!/bin/bash
# Nik Sultana, UPenn, August 2020
set -e

TESTS=( "MORE_PARAMS=\"--flightplan_emit_JSON program1.json\" ./ALV_test.sh"
        "MORE_PARAMS=\"--flightplan_emit_JSON program2.json\" ./ALV_test.sh -s 1"
        "MORE_PARAMS=\"--flightplan_emit_JSON program3.json\" ./ALV_test.sh -s 2"

        "MORE_PARAMS=\"--flightplan_emit_JSON program4.json\" ./ALV_test.sh -r HL"
        "./ALV_test.sh -s 1 -r HL || true"
        "./ALV_test.sh -s 2 -r HL || true"

        "MORE_PARAMS=\"--flightplan_emit_JSON program5.json\" ./ALV_FW_test.sh"
        "MORE_PARAMS=\"--flightplan_emit_JSON program6.json\" ./ALV_FW_test.sh -s 1"
        "MORE_PARAMS=\"--flightplan_emit_JSON program7.json\" ./ALV_FW_test.sh -r HL"
        "MORE_PARAMS=\"--flightplan_emit_JSON program8.json\" ./ALV_FW_test.sh -r HL -s 1"

        "MORE_PARAMS=\"--flightplan_emit_JSON program9.json\" ./qos_test.sh"
        "MORE_PARAMS=\"--flightplan_emit_JSON program10.json\" ./qos_test.sh -r HL"
        "MORE_PARAMS=\"--flightplan_emit_JSON program11.json\" ./qos_test.sh -s 1"
        "./qos_test.sh -s 1 -r HL || true"

        "MORE_PARAMS=\"--flightplan_emit_JSON program12.json\" ./basic_tunnel_test.sh -r HL"
        "MORE_PARAMS=\"--flightplan_emit_JSON program13.json\" ./basic_tunnel_test.sh -r Full"
        "./basic_tunnel_test.sh -r HL -s 1 || true"
        "MORE_PARAMS=\"--flightplan_emit_JSON program14.json\" ./basic_tunnel_test.sh -r Full -s 1"

        "MORE_PARAMS=\"--flightplan_emit_JSON program15.json\" ./Crosspod_test.sh -v 0 -s 0 -r Full"
        "./Crosspod_test.sh -v 0 -s 0 -r HL || true"
        "MORE_PARAMS=\"--flightplan_emit_JSON program16.json\" ./Crosspod_test.sh -v 0 -s 1 -r Full"
        "./Crosspod_test.sh -v 0 -s 1 -r HL || true"

        "MORE_PARAMS=\"--flightplan_emit_JSON program17.json\" ./Crosspod_test.sh -v 1 -s 0 -r Full"
        "MORE_PARAMS=\"--flightplan_emit_JSON program18.json\" ./Crosspod_test.sh -v 1 -s 0 -r HL"
        "MORE_PARAMS=\"--flightplan_emit_JSON program19.json\" ./Crosspod_test.sh -v 1 -s 1 -r Full"
        "MORE_PARAMS=\"--flightplan_emit_JSON program20.json\" ./Crosspod_test.sh -v 1 -s 1 -r HL"
      )

for TEST in "${TESTS[@]}"
do
  echo ${TEST}
  eval ${TEST} > /dev/null
done
