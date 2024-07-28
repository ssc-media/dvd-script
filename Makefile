
ffmpeg=ffmpeg -hide_banner
ffmpeg_dvd_opt=-vf yadif=1,setsar=1:1,scale=720:480,tinterlace=4 -target ntsc-dvd -flags +ilme+ildct -b:v 2500k
dvd_max=4707319808
loudnorm_i=-23.0

include files.mak

.SUFFIXES: .mpg .mp4 .flv .mkv
.PRECIOUS: .txt .mpg .flv .mkv

step0: \
	step0-remove-old-files

step0-remove-old-files:
	rm -f ../$(shell date -d '${date} -14 days' +%Y%m%d)/*.${obs_recording_fmt}
	rm -f ../$(shell date -d '${date} -14 days' +%Y%m%d)/*.mpg
	rm -f ../$(shell date -d '${date} -14 days' +%Y%m%d)/*.iso

$(has_files_mak)files.mak:
	./script/step0.sh > $@.t
	mv $@.t $@

step1: ${obs_edited}

obs-${date}-cut.loudnorm.txt: ${obs_recording}
	${ffmpeg} ${obs_recording_inp_opt} -i ${obs_recording} -map 0:a:0 \
		-filter_complex "loudnorm=i=${loudnorm_i}:print_format=summary" \
		-f null - 2> .$@ < /dev/null
	mv .$@ $@

step2: step2_encode step2_dvd_${run_dvd}

${obs_edited}: ${obs_recording} obs-${date}-cut.loudnorm.txt
	${ffmpeg} ${obs_recording_inp_opt} -i ${obs_recording} -map 0:v -map 0:a:0 \
		-af "loudnorm=i=${loudnorm_i}:$$(./script/loudnorm2opt.awk obs-${date}-cut.loudnorm.txt)" \
		-c:v copy -c:a aac -b:a 253k -y .${obs_edited}
	mv .${obs_edited} ${obs_edited}

step2_encode: ${dvd_sources}
	echo skip_dvdvideo_encode=y >> files.mak

step2_dvd_y: dvdvideo-${date}.xml dvdvideo-${date}.iso
step2_dvd_${run_dvd}:

ifneq (${skip_dvdvideo_encode},y)
%.mpg: %.${obs_recording_fmt}
	${ffmpeg} -i $< ${ffmpeg_dvd_opt} -y $@.mpg
	mv $@.mpg $@

%.mpg: %.mp4
	${ffmpeg} -i $< ${ffmpeg_dvd_opt} -y $@.mpg
	mv $@.mpg $@

%.mpg: %.${obs_recording_fmt}
	${ffmpeg} -i $< ${ffmpeg_dvd_opt} -y $@.mpg
	mv $@.mpg $@
endif

dvdvideo-${date}.xml:
	./script/mkdvdvideo-xml.sh $(dvd_sources) > $@.t
	mv $@.t $@

dvdvideo-${date}.iso: dvdvideo-${date}.xml ${dvd_sources}
	./script/mkdvdvideo-iso.sh dvdvideo-${date}.xml $@.iso
	test `wc -c < $@.iso` -le ${dvd_max}
	mv $@.iso $@

burn: dvdvideo-${date}.iso
	test `wc -c < dvdvideo-${date}.iso` -le ${dvd_max}
	env CDR_NODMATEST=1 dvdrecord -v -dao -speed=4 dev=/dev/cdrom fs=1024k -eject ${PWD}/dvdvideo-${date}.iso
