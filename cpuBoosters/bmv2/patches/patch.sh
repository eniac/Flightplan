#!/bin/bash

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO to patch"
    exit 1
fi

ANY_FAILURES=0

patch_if_diff() {
    # Checks if the patch works in reverse
    patch -R -s -f --dry-run $1 $2 > /dev/null
    # If it doesn't, try it in the forward direction, otherwise already applied
    if [[ $? != 0 ]]; then
        patch $1 $2
        if [[ $? != 0 ]]; then
            echo "Failed to patch!"
            ANY_FAILURES=1;
        else
            echo "Applied..."
        fi
    else
        echo "Already applied..."
    fi
}

for PATCHFILE in $( find . -name '*.patch'); do
    echo -n "Applying patchfile $PATCHFILE: "
    patch_if_diff $BMV2_REPO/${PATCHFILE%.patch} $PATCHFILE
done

exit $ANY_FAILURES
