#!/bin/bash

#script to determine whether the device is currently on fire, easily adaptable into an extension attribute

btemp=`istats battery temp | tr -d "Baterymp: °C" | sed 's/\..*//'`
ctemp=`istats cpu temp | tr -d "CPUtemp: " | sed 's/\..*//'`

if (( $btemp > 40 )) ; then
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility-title "Warning" -description "Your computer is on fire. Please call 0118 999 881 99 9119 7253 for emergency assistance." -button1 "Ok"
	echo "Status: The battery is currently on fire. Battery temperature is `echo $btemp`° C"
	exit 0
fi

if (( $ctemp > 70 )) ; then
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility-title "Warning" -description "Your computer is on fire. Please call 0118 999 881 99 9119 7253 for emergency assistance." -button1 "Ok"
	echo "Status: CPU is currently on fire. CPU Temperature is `echo $ctemp`° C"
fi
