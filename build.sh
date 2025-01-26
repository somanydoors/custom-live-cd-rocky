#!/bin/sh

ksflatten \
    -c /in/custom.ks \
    -o /out/live.ks

livecd-creator --verbose \
    --config=/out/live.ks \
    --fslabel="RockyLiveCD" \
    --cache=/var/cache/live
