if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO to patch"
    exit 1
fi

patch_if_diff() {
    # Checks if the patch works in reverse
    patch -R -s -f --dry-run $1 $2 > /dev/null
    # If it doesn't, try it in the forward direction, otherwise already applied
    if [[ $? != 0 ]]; then
        patch $1 $2
    fi
}

patch_if_diff $BMV2_REPO/configure.ac configure.ac.patch
patch_if_diff $BMV2_REPO/targets/Makefile.am Makefile.am.patch
