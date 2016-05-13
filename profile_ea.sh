#!/bin/bash

profilechecker=`sudo profiles -P | grep profileIdentifier | grep 21AD9086-8A4C-4AC5-91EE-20F418B4B298`


if [ "$profilechecker" != "" ]
then
	echo "<result>Yes</result>"
else
	echo "<result>No</result>"
fi
