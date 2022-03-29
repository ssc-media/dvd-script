#! /bin/bash

inp=''
out=''
threshold=-1dB # TODO: target -23 LUFS
makeup=0dB
max_target=-0.3dB
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
PATH=/bin:/usr/bin:/usr/sbin:/usr/local/bin

while (($#>0)); do
	case "$1" in
		*)
			if test -z "$inp"; then
				inp="$1"
			elif test -z "$out"; then
				out="$1"
			else
				echo "Error $1" >&2
				exit 1
			fi
			shift
			;;
	esac
done

t=$(mktemp -d)

function doit
{
	ffmpeg -loglevel error -i "$inp" -map 0:a -af "acompressor=threshold=$threshold:ratio=4:makeup=$makeup" "$@"
}

doit $t/out1.wav

ffmpeg -i $t/out1.wav -af volumedetect,ebur128=framelog=verbose -f null /dev/null 2>$t/out1.volume
max_volume=$(awk '/.Parsed_volumedetect_0 @ .* max_volume: /{print $(NF-1)}' $t/out1.volume)
loudness=$(awk '$1=="I:" && $3=="LUFS" {lufs=$2} END {print lufs}' $t/out1.volume)

# threshold=$(awk -v makeup=$makeup -v max_volume=$max_volume -v max_target=$max_target -v loudness=$loudness 'BEGIN {print max_target-max_volume+makeup "dB"}')

makeup=$(awk -v makeup=$makeup -v max_volume=$max_volume -v max_target=$max_target -v loudness=$loudness 'BEGIN {
	add = max_target-max_volume
	loudness1 = loudness + add
	if (loudness1 > -23)  {
		print "add="add" loudness="loudness" loudness1="loudness1 > "/dev/stderr"
		# TODO: if too loud, at first, try middle of max_target and -23 LUFS.
		add = (add + (-23-loudness)) / 2;
	}
	makeup1 = makeup + add
	additional_filter = ""
	if (makeup1 < 0) {
		additional_filter = sprintf(",volume=%f", exp(makeup1 * .11512925464970228420))
		makeup1 = 0
	}
	print int(makeup1) "dB" additional_filter
}')

echo "Info: threshold=$threshold makeup=$makeup" >&2
doit $out

rm -rf $t
