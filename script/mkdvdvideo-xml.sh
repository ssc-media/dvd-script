#! /bin/bash

cat <<-EOF
<dvdauthor>
<vmgm />
<titleset>
<titles>
<pgc>
EOF

for f in "$@"; do
	echo "<vob file=\"$f\" />"
done

cat <<-EOF
</pgc>
</titles>
</titleset>
</dvdauthor>
EOF
