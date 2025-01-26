#!/bin/sh

ksflatten \
    -c "/in/${CUSTOM_KICKSTART}.ks" \
    -o "/out/${FLATTENED_KICKSTART}.ks"

livecd-creator \
    --verbose \
    --config="/out/${FLATTENED_KICKSTART}.ks" \
    --fslabel="${CD_LABEL}" \
    --cache=/var/cache/live
