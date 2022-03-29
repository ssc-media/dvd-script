
ffmpeg=env LD_LIBRARY_PATH=/usr/local/lib: /usr/local/bin/ffmpeg -hide_banner
dvd_max=4707319808

include files.mak

step0: \
	step0-remove-old-files

step0-remove-old-files:
	rm -f ../$(shell date -d '${date} -14 days' +%Y%m%d)/*.flv
	rm -f ../$(shell date -d '${date} -14 days' +%Y%m%d)/*.mpg
	rm -f ../$(shell date -d '${date} -14 days' +%Y%m%d)/*.iso

$(has_files_mak)files.mak:
	./script/step0.sh > $@.t
	mv $@.t $@

step1: ${obs_flv_cut} ${obs_wav}
	echo skip_video_encode_obs=y >> files.mak

ifneq (${skip_video_encode_obs},y)
${obs_flv_cut}: ${obs_flv}
	${ffmpeg} ${obs_flv_inp_opt} -i ${obs_flv} -c copy .$@
	mv .$@ $@
endif

${obs_wav}: ${obs_flv_cut}
	${ffmpeg} -i ${obs_flv_cut} ${obs_wav}

ifeq (${volume_auto},y)
obs-${date}-audio-edit.wav: ${obs_wav}
	./script/autogain.sh ${obs_wav} $@
endif

step2: ${obs_edited} dvdvideo-${date}.mpg step2_dvd_${run_dvd}

${obs_edited}: ${obs_flv_cut} obs-${date}-audio-edit.wav
	${ffmpeg} -i ${obs_flv_cut} -i obs-${date}-audio-edit.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 253k -y .${obs_edited}
	mv .${obs_edited} ${obs_edited}

step2_dvdvideo_y: dvdvideo-${date}.mpg
step2_dvdvideo_${run_dvdvideo}:

step2_dvd_y: dvdvideo-${date}.xml dvdvideo-${date}.iso
step2_dvd_${run_dvd}:

ifneq (${skip_dvdvideo_encode},y)
dvdvideo-${date}.mpg: ${obs_edited}
	${ffmpeg} -i ${obs_edited} -vf yadif=1,setsar=1:1,scale=720:480,tinterlace=4 -target ntsc-dvd -flags +ilme+ildct -b:v 2500k -y $@.mpg
	mv $@.mpg $@
	echo skip_dvdvideo_encode=y >> files.mak
endif

dvdvideo-${date}.xml:
	./script/mkdvdvideo-xml.sh $(dvd_sources) > $@.t
	mv $@.t $@

dvdvideo-${date}.iso: dvdvideo-${date}.xml dvdvideo-${date}.mpg
	./script/mkdvdvideo-iso.sh dvdvideo-${date}.xml $@.iso
	test `wc -c < $@.iso` -le ${dvd_max}
	mv $@.iso $@

burn: dvdvideo-${date}.iso
	test `wc -c < dvdvideo-${date}.iso` -le ${dvd_max}
	dvdrecord -v -dao -speed=6 dev=/dev/cdrom -eject ${PWD}/dvdvideo-${date}.iso
