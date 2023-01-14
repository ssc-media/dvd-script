#! /bin/bash

date=$(basename $(pwd))
obs_recording_ss=0
case $(LANG=C date -d $date +%a) in
	Fri)
		obs_recording_ss=45
		run_dvd=n
		;;
	Sun)
		obs_recording_ss=15
		run_dvd=y
		ymd_fri="$(date -d "$date - 2days" +%Y%m%d)"
		dvd_sources="$(ls ../${ymd_fri}/dvdvideo-${ymd_fri}.mpg || :) dvdvideo-${date}.mpg)"
		;;
esac
recording=$(ls -S ~/Videos/obs-${date}-*.{flv,mkv} | head -n 1)
if (($? > 0)); then exit 1; fi

case "$recording" in
	*.mkv)
		obs_recording_fmt=mkv
		;;
	*.flv)
		obs_recording_fmt=flv
		;;
esac

cat <<-EOF
# tag
date=$date

# inputs
obs_recording_fmt=$obs_recording_fmt
obs_recording=$recording
obs_recording_inp_opt=-ss ${obs_recording_ss}
dvd_sources=${dvd_sources}

# outputs
obs_recording_cut=obs-${date}-cut.$obs_recording_fmt
obs_wav=obs-${date}-cut.wav
obs_edited=dvdvideo-${date}.$obs_recording_fmt

# flow switches
run_dvd=${run_dvd}
has_files_mak=y

# detailed flow switches
volume_auto=y
EOF
