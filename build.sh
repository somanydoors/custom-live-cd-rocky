#!/bin/sh

# Build the Kickstart file if one doesn't exist
if ! [ -f "/in/${CUSTOM_KICKSTART}.ks" ]; then

	# Include the live CD Kickstarts from the project
	echo '%include /usr/share/rocky-kickstarts/live/9/x86_64/prod/rocky-live-base.ks' > "/in/${CUSTOM_KICKSTART}.ks"

	if [ "${SSH_ENABLED}" ]; then

		# Enable the SSH service
		echo 'services --disabled="" --enabled="NetworkManager,ModemManager,sshd"' >> "/in/${CUSTOM_KICKSTART}.ks"

		if [ ! -z "${SSH_AUTHORIZED_KEY}" ]; then

			# Add a step to the custom Kickstart to write the SSH key to root's authorized_keys
			cat <<-EOF >> "/in/${CUSTOM_KICKSTART}.ks"
			%post --nochroot
			echo "${SSH_AUTHORIZED_KEY}" > \$INSTALL_ROOT/root/.ssh/authorized_keys
			chown root:root \$INSTALL_ROOT/root/.ssh/authorized_keys
			chmod u=rw,go= \$INSTALL_ROOT/root/.ssh/authorized_keys

			%end

			EOF
		fi
	fi
fi

ksflatten \
    -c "/in/${CUSTOM_KICKSTART}.ks" \
    -o "/out/${FLATTENED_KICKSTART}.ks"

livecd-creator \
    --verbose \
    --config="/out/${FLATTENED_KICKSTART}.ks" \
    --fslabel="${CD_LABEL}" \
    --cache=/var/cache/live
