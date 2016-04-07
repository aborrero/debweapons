#!/bin/bash

EMAIL="arturo.borrero.glez@gmail.com"

BTS_BIN=$(which bts)
if [ ! -x $BTS_BIN ] ; then
	echo "E: no bts binary found" >&2
	exit 1
fi

BUG_LIST=$($BTS_BIN select submitter:${EMAIL} archive:both)

for bug in $BUG_LIST ; do
	ts=$($BTS_BIN status $bug | grep date | awk -F' ' '{print $2}')
	if ! grep ^[0-9]*$ <<< $ts > /dev/null ; then
		echo "W: failed to query date of bug #${bug}"
		continue
	fi
	echo -n "bug #$bug year "
	date -d @$ts +%Y
done

exit 0
