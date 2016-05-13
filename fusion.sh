#!/bin/bash

counter=`diskutil cs list`
coredrives=`grep -o "Physical" <<<"$counter" | wc -l | tr -d ' '`

if [ "$coredrives" == "1" ]
then
	echo "<result>Fusion Drive</result>"
else
	echo "<result>Non Fusion Drive</result>"
fi
