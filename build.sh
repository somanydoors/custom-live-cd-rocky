#!/bin/sh

# Build the Kickstart file if one doesn't exist
if ! [ -f "/in/${CUSTOM_KICKSTART}.ks" ]; then

	# Include the live CD Kickstarts from the project
	echo '%include /usr/share/rocky-kickstarts/live/9/x86_64/prod/rocky-live-base.ks' >"/in/${CUSTOM_KICKSTART}.ks"

	if [ "${SSH_ENABLED}" ]; then

		# Enable the SSH service
		echo 'services --disabled="" --enabled="NetworkManager,ModemManager,sshd"' >>"/in/${CUSTOM_KICKSTART}.ks"

		if [ ! -z "${SSH_AUTHORIZED_KEY}" ]; then

			# Add a step to the custom Kickstart to write the SSH key to root's authorized_keys
			cat <<-EOF >>"/in/${CUSTOM_KICKSTART}.ks"
				%post --nochroot
				echo "${SSH_AUTHORIZED_KEY}" > \$INSTALL_ROOT/root/.ssh/authorized_keys
				chown root:root \$INSTALL_ROOT/root/.ssh/authorized_keys
				chmod u=rw,go= \$INSTALL_ROOT/root/.ssh/authorized_keys

				%end

			EOF
		fi

		if [ ! -z "${SSH_KEY_URL}" ]; then

			# Write a script to download the keys from URL and append them to authorized_keys
			cat <<-EOF >/tmp/authorized-keys-from-url
				#!/bin/sh
				touch /root/.ssh/authorized_keys
				chown root:root /root/.ssh/authorized_keys
				chmod u=rw,go= /root/.ssh/authorized_keys
				curl -s "${SSH_KEY_URL}" >> /root/.ssh/authorized_keys
			EOF

			# Write a service to run the keys script
			cat <<-EOF >>/tmp/authorized-keys-from-url.service
				[Unit]
				Description=Download SSH public keys from URL
				After=network-online.target
				Wants=network-online.target

				[Service]
				Type=oneshot
				ExecStart=/usr/local/bin/authorized-keys-from-url
				RemainAfterExit=true

				[Install]
				WantedBy=multi-user.target
			EOF

			# Add tasks to the custom kickstart to copy the script and service into the image and enable the service at startup
			cat <<-EOF >>"/in/${CUSTOM_KICKSTART}.ks"
				%post --nochroot
				cp /tmp/authorized-keys-from-url \$INSTALL_ROOT/usr/local/bin
				cp /tmp/authorized-keys-from-url.service \$INSTALL_ROOT/etc/systemd/system

				%end

				%post
				systemctl enable authorized-keys-from-url.service

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
