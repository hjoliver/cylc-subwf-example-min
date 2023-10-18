#!/usr/bin/env bash
set -eu

# Print to stdout a subworklow ID that is unique for a given:
#  - subworkflow name
#  - main workflow ID
#  - main workflow cycle point
# for side-by-side main and subworkflow run-dirs.
#
# Examples:
#   (1) sub, main, 3 ----------------> main-p3-sub
#   (2) sub, main/run1, 3 -----------> main-run1-p3-sub
#   (3) sub, cat/main/run1, 3 -------> cat/main-run1-p3-sub
#       sub, cat/dog/main/run1, 3 ---> cat/dog/main-run1-p3-sub

SUB=$1
MAIN_ID=$2
MAIN_PT=$3

if [[ $SUB == */* ]]; then
   >&2 echo "ERROR: sub-workflow name must be flat: $SUB"
   exit 1
fi

if [[ $MAIN_ID != */* ]]; then
    # (1) no run-name 
    SUBWF_ID="${MAIN_ID}-${MAIN_PT}-${SUB}"
else 
    RUN=$(basename $MAIN_ID)
    PARENTS=$(dirname $MAIN_ID)
    if [[ $PARENTS != */* ]]; then
        # (2) parent but no grandparents
        SUBWF_ID="${PARENTS}-${RUN}-${MAIN_PT}-${SUB}"
    else
        # (3) parent and grandparents
        PARENT=$(basename $PARENTS)
        GPARENTS=$(dirname $PARENTS)
        SUBWF_ID="${GPARENTS}/${PARENT}-${RUN}-${MAIN_PT}-${SUB}"
    fi
fi
echo $SUBWF_ID 
