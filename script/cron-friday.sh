#! /bin/bash

cd ~/dvd

d=$(date -d 'this Friday' +%Y%m%d)

if test ! -d $d; then
	git clone -q $(date -d 'last Sunday' +%Y%m%d) $d
	ln -sf $d/script ./
fi

cd $d || exit 1

make step0 &> step0.out || true
make -k step1 &> step1.out || true
make -k step2 &> step2.out

rm -f obs-${d}-cut.wav obs-${d}-audio-edit.wav
