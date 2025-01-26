#!/bin/sh

ksflatten \
    -c /in/custom.ks \
    -o "/out/${FLATTENED_KICKSTART}.ks"

livecd-creator --verbose \
    --config="/out/${FLATTENED_KICKSTART}.ks" \
    --fslabel="${CD_LABEL}" \
    --cache=/var/cache/live
