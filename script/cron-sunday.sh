#! /bin/bash

cd ~/dvd

d=$(date -d 'this Sunday' +%Y%m%d)

if test ! -d $d; then
	git clone -q bare $d
	ln -sf $d/script ./
fi

while lsof ~/Videos/obs-${d}-10????.??? | awk -v r=1 '$4~/w/{r=0} END{exit(r)}'; do
	sleep 2m
done

cd $d || exit 1

function msg_failure
{
	( echo Failed to burn DVD; cat "$@" | grep -v '\r' | tail ) |
	~/script/dd.py --channel 'dvd-automation' --send-text -
}

make step0 &> step0.out || true
make -k step1 &> step1.out || true
make -k step2 &> step2.out || msg_failure step2.out

rm -f obs-${d}-cut.wav obs-${d}-audio-edit.wav

if test -e dvdvideo-${d}.iso; then
	echo 'timeout 4d ./script/burn-loop.sh &>> burn-loop-batch.out' | batch &> burn-loop-batch.out
fi
