EMAIL="arturo.borrero.glez@gmail.com"

BTS_BIN=$(which bts)
if [ ! -x $BTS_BIN ] ; then
	echo "E: no bts binary found" >&2
	exit 1
fi

BUG_LIST=$($BTS_BIN select submitter:${EMAIL} archive:both)
BUG_LIST="$BUG_LIST $($BTS_BIN select correspondent:${EMAIL} archive:both)"
BUG_LIST=$(sort -n <<< "$BUG_LIST" | uniq)

for bug in $BUG_LIST ; do
	bts_status=$($BTS_BIN status $bug)
	if [ -z "$bts_status" ] ; then
		echo "W: failed to query: bts status #${bug}" >&2
		continue
	fi

	ts=$(grep date <<< "$bts_status" | awk -F' ' '{print $2}')
	if ! grep ^[0-9]*$ <<< $ts > /dev/null ; then
		echo "W: failed to resolve date of bug #${bug}" <&2
		continue
	fi

	package=$(grep ^package <<< "$bts_status" | awk -F' ' '{print $2}')
	if [ -z "$package" ] ; then
		echo "W: failed to resolve package of bug #${bug}" >&2
		continue
	fi

	year=$(date -d @$ts +%Y)
	echo "bug #$bug [year $year] package $package"
done
exit 0
