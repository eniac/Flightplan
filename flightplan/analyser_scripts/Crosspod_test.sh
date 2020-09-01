#!/bin/bash
# Nik Sultana, UPenn, August 2020
set -e

P4_FILE=

RUNTIME=Full
MORE_PARAMS="${MORE_PARAMS} --flightplan_switch_md switch_metadata_t --flightplan_standard_md meta -I /home/nik/P4Boosters/Wharf/Sources"
SPLIT_VARIATION=0
PROGRAM_VERSION=

while getopts "r:s:v:p:" OPTS
do
  case "${OPTS}" in
      r)
            RUNTIME=${OPTARG}
            ;;
      s)
            SPLIT_VARIATION=${OPTARG}
            ;;
      v)
            PROGRAM_VERSION=${OPTARG}
            ;;
      p)
            MORE_PARAMS="${OPTARG} ${MORE_PARAMS}"
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

case "${PROGRAM_VERSION}" in
    0)
          P4_FILE=/home/nik/P4Boosters/Wharf/splits/ALV_Complete/ALV_Complete.p4
          ;;
    1)
          P4_FILE=/home/nik/P4Boosters/Wharf/splits2/ALV_Complete_1_hl3_unsplit/ALV_Complete_hl3_unsplit.p4
          MORE_PARAMS="--flightplan_allow_cflow --flightplan_allow_metaIO ${MORE_PARAMS}"
          ;;
    *)
	  echo "Error: Unrecognised program version (-v '${PROGRAM_VERSION}')." >&2
          exit 1
          ;;
esac

if [ -z "${P4_FILE}" ]
then
    echo "Error: Unspecified program version (-v)." >&2
    exit 1
fi

source /home/nik/p4c/Wharf/analyser_scripts/run_v2.sh
