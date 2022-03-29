#! /bin/bash

rm -rf DVD_Dir

dvdauthor -o DVD_Dir -x $1
ret=$?
mkisofs -dvd-video -o $2 DVD_Dir
ret=$((ret | $?))

rm -rf DVD_Dir

size=$(wc -c < $2)
truncate -s $((size+2048*1024)) $2
exit $ret
