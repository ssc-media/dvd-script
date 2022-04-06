#! /bin/bash

opt_first_cont=--first
send_mail=1

function wait_blank_dvd
{
	if udevadm info -q env -n /dev/cdrom | grep 'ID_CDROM_MEDIA_STATE=blank'; then
		return
	fi
	udevadm monitor |
	while read line; do
		case "$line" in
			*change*sr*)
				break ;;
		esac
	done
}

while wait_blank_dvd; do
	if make burn; then
		date -R >> burn-loop.log
		opt_first_cont=--continue
		send_mail=1
	else
		if ((send_mail)); then
			$(dirname $0)/burn-email.sh ${opt_first_cont}
			send_mail=0
		fi
	fi
done
