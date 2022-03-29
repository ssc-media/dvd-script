#! /bin/bash

flg_first=0
flg_continue=0
xml=''

. ~/.config/burn-dvd.rc

while (($# > 0)); do
	case "$1" in
		--first)
			flg_first=1
			shift ;;
		--continue)
			flg_continue=1
			shift ;;
		*.xml)
			xml="$1"
			shift ;;
		*)
			echo "Error: $1" >&2
			exit 1
	esac
done

if test -z "$xml"; then
	date="$(awk -v FS='=' '$1=="date"{ date=$2 } END { print date }' $(dirname $0)/../files.mak)"
	xml=$(dirname $0)/../dvdvideo-${date}.xml
fi

if test -f "$xml"; then
	vobfiles="$(awk -v FS='"' '/vob.file=/{print $2}' $xml)"
	s_dates="$(for v in $vobfiles; do basename "$v"; done | awk -v FS='[-.]' '{s=$(NF-1); printf("%s%d月%d日", NR>1?"と":"", substr(s,5,2), substr(s,7,2))}')"
fi

if test -n "$s_dates"; then
	s_dates_no="${s_dates}の"
fi

if ((flg_first+flg_continue==0)); then
	exit 0
fi

if test -n "$recipients"; then
	{
		echo "${text_to}、"
		echo

		if ((flg_first)); then
			cat <<-EOF
			${s_dates_no}DVD-Videoを書き込む準備が出来ました。
			空のDVD-Rをドライブに入れて頂けないでしょうか。

			よろしくお願いいたします。
			EOF
		elif ((flg_continue)); then
			cat <<-EOF
			${s_dates_no}DVD-Videoの$(wc -l < burn-loop.log)枚目の書き込みが完了しました。
			次のディスクに書き込むため、空のDVD-Rをドライブに入れかえて頂けないでしょうか。

			よろしくお願いいたします。
			EOF
		fi
	} |
	~/script/mail-sscmedia.py \
		-s 'DVD Video' \
		${mail_opts} \
		${recipients}
fi

if ((flg_first)); then
	msg="${s_dates_no}DVD-Videoを書き込む準備が出来ました。空のDVD-Rをドライブに入れると、書き込みが始まります。"
elif ((flg_continue)); then
	msg="${s_dates_no}DVD-Videoの$(wc -l < burn-loop.log)枚目の書き込みが完了しました。次のディスクをドライブに入れると、書き込みが始まります。"
else
	msg=''
fi
if test -n "$msg"; then
	~/script/dd.py --channel 'automation' --send-text "$msg"
fi
