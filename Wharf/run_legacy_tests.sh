#!/bin/bash -e

DESCRIBE=0
while [ "${1:-}" != "" ]; do
    case "$1" in
      "-d" | "--describe")
        DESCRIBE=1
        ;;
       *)
        echo "Usage $0 [--describe]"
        echo "(--describe option shows only the script's purpose)"
        exit 1
    esac
    shift
done

if [[ $DESCRIBE == 1 ]]; then
    $WHARF_REPO/bmv2/tclust/tclust_mcrouter.sh --describe
    $WHARF_REPO/bmv2/tclust/tclust_ufw.sh --describe
    $WHARF_REPO/bmv2/tclust/tclust_snort.sh --describe
    exit 0
fi

LOG_DIR=$WHARF_REPO/bmv2/test_output/tclust_test_output

mkdir -p ${LOG_DIR}

legacy_test() {
  TITLE=$1
  SCRIPT=$WHARF_REPO/bmv2/tclust/$2
  if [[ $# == 3 ]]; then
      FLAGS=$3;
  else
      FLAGS="";
  fi

  OUTPUT="$LOG_DIR/$TITLE"
  echo "Running $TITLE"

  echo "$SCRIPT $FLAGS > $OUTPUT.stdout"
  bash $SCRIPT $FLAGS > $OUTPUT.stdout

  if [ $? -eq 0 ]; then
      echo "SUCCESS";
  else
      echo "FAILED";
  fi
}

legacy_test mcrouter_alone tclust_mcrouter.sh
legacy_test mcrouter_complete tclust_mcrouter.sh --complete
legacy_test ufw_alone tclust_ufw.sh
legacy_test ufw_complete tclust_ufw.sh --complete
legacy_test snort tclust_snort.sh
legacy_test snort_complete tclust_snort.sh --complete
