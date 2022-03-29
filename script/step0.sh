#! /bin/bash

date=$(basename $(pwd))
obs_flv_ss=0
case $(LANG=C date -d $date +%a) in
	Fri)
		obs_flv_ss=45
		run_dvd=n
		;;
	Sun)
		obs_flv_ss=15
		run_dvd=y
		ymd_fri="$(date -d "$date - 2days" +%Y%m%d)"
		dvd_sources="../${ymd_fri}/dvdvideo-${ymd_fri}.mpg dvdvideo-${date}.mpg"
		;;
esac
flv=$(ls -S ~/Videos/obs-${date}-*.flv | head -n 1)
if (($? > 0)); then exit 1; fi



cat <<-EOF
# tag
date=$date

# inputs
obs_flv=$flv
obs_flv_inp_opt=-ss ${obs_flv_ss}
dvd_sources=${dvd_sources}

# outputs
obs_flv_cut=obs-${date}-cut.flv
obs_wav=obs-${date}-cut.wav
obs_edited=obs-${date}-edited.flv

# flow switches
run_dvd=${run_dvd}
has_files_mak=y

# detailed flow switches
volume_auto=y
EOF
