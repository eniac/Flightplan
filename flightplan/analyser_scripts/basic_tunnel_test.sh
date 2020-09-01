#!/bin/bash
# Nik Sultana, UPenn, August 2020
set -e

P4_FILE=/home/nik/p4lang/tutorials_newer/exercises/basic_tunnel/solution/basic_tunnel.p4

RUNTIME=Full
#MORE_PARAMS=
SPLIT_VARIATION=0

while getopts "r:s:" OPTS
do
  case "${OPTS}" in
      r)
            RUNTIME=${OPTARG}
            ;;
      s)
            SPLIT_VARIATION=${OPTARG}
            ;;
      :)
            echo "Error: Missing argument for -${OPTARG}." >&2
            exit 1
            ;;
      *)
            echo "Error: Unrecognised parameter -${OPTARG}." >&2
            exit 1
            ;;
  esac
done

case "${RUNTIME}" in
    Full)
          # Do nothing
	  true
          ;;
    HL)
          MORE_PARAMS="--flightplan_offload_cflow --flightplan_routing_segment FlightStart ${MORE_PARAMS}"
          ;;
    *)
          echo "Error: Unrecognised runtime ${RUNTIME}." >&2
          exit 1
          ;;
esac

case "${SPLIT_VARIATION}" in
    0)
          # Do nothing
	  true
          ;;
    1)
          MORE_PARAMS="-DFP_ANNOTATE ${MORE_PARAMS}"
          ;;
    *)
          echo "Error: Unrecognised split variation ${SPLIT_VARIATION}." >&2
          exit 1
          ;;
esac

source /home/nik/p4c/Wharf/analyser_scripts/run_v2.sh
