#!/bin/sh

# Build the Kickstart file if one doesn't exist
if ! [ -f "/in/${CUSTOM_KICKSTART}.ks" ]; then

	# Include the live CD Kickstarts from the project
	echo '%include /usr/share/rocky-kickstarts/live/9/x86_64/prod/rocky-live-base.ks' > "/in/${CUSTOM_KICKSTART}.ks"

fi

ksflatten \
    -c "/in/${CUSTOM_KICKSTART}.ks" \
    -o "/out/${FLATTENED_KICKSTART}.ks"

livecd-creator \
    --verbose \
    --config="/out/${FLATTENED_KICKSTART}.ks" \
    --fslabel="${CD_LABEL}" \
    --cache=/var/cache/live
