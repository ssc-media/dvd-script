#! /bin/bash

cd ~/dvd

d=$(date -d 'this Friday' +%Y%m%d)

if test ! -d $d; then
	git clone -q $(date -d 'last Sunday' +%Y%m%d) $d
	ln -sf $d/script ./
fi

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
