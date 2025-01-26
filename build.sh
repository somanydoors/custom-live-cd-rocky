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
				%post
				echo "${SSH_AUTHORIZED_KEY}" > /root/.ssh/authorized_keys
				chown root:root /root/.ssh/authorized_keys
				chmod u=rw,go= /root/.ssh/authorized_keys

				%end

			EOF
		fi

		if [ ! -z "${SSH_KEY_URL}" ]; then

			# Add tasks to the custom kickstart to copy the script and service into the image and enable the service at startup
			cat <<-EOF >>"/in/${CUSTOM_KICKSTART}.ks"
				%post
				echo "Writing /usr/local/bin/authorized-keys-from-url..."
				cat <<-END >/usr/local/bin/authorized-keys-from-url
				#!/bin/sh
				touch /root/.ssh/authorized_keys
				chown root:root /root/.ssh/authorized_keys
				chmod u=rw,go= /root/.ssh/authorized_keys
				echo "Fetching keys from ${SSH_KEY_URL}..."
				curl -s "${SSH_KEY_URL}" >> /root/.ssh/authorized_keys
				echo "Deduplicating keys..."
				sort -u /root/.ssh/authorized_keys -o /root/.ssh/authorized_keys
				END

				chmod u=rwx,go=rx /usr/local/bin/authorized-keys-from-url
				chown root:root /usr/local/bin/authorized-keys-from-url

				echo "Writing /etc/systemd/system/authorized-keys-from-url.service..."
				cat <<-END >/etc/systemd/system/authorized-keys-from-url.service
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
				END

				echo "Enabling authorized-keys-from-url.service..."
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
