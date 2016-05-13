#!/bin/bash -x

timezone=`date '+%Z'`
if [ "$timezone" == "CDT" ]
then
	echo "<result>Badgertime</result>"
else
	echo "<result>Somewhere over the rainbow</result>"
fi
