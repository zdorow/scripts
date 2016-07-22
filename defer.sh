#!/bin/bash

consoleuser=$(ls -l /dev/console | awk '{print $3}')

touch "/Library/Application Support/JAMF/.deferCounter"
chown $consoleuser "/Library/Application Support/JAMF/.deferCounter"
chown $consoleuser "/Library/Application Support/JAMF/.userdelay.plist"

su $consoleuser << '_EOF_'

policyID="3"
userdelay="/Library/Application Support/JAMF/.userdelay.plist"

if [[ ! -s "/Library/Application Support/JAMF/.deferCounter" ]] ; then
	echo 0 > "/Library/Application Support/JAMF/.deferCounter"
fi

deferCounter=`cat "/Library/Application Support/JAMF/.deferCounter"`
function incrementDefer {
count=`cat "/Library/Application Support/JAMF/.deferCounter"`
count=$[$count+1]
echo $count > "/Library/Application Support/JAMF/.deferCounter"
}

function installPrompt {
	prompt2=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "Notice" -description "Would you like to install all system updates, or only those that do not require a restart?" -button1 "All" -button2 "No Restart"`
	if [[ "$prompt2" == "0" ]] ; then
		# ALL
		jamf policy -id 5
	else
		# NO RESTART
		jamf policy -id 4
	fi
}

function calculateDefer {
	currentEpoch=`date +%s`
	newEpoch=`python -c "print $currentEpoch+$dtime"`
	newTime=`date -r $newEpoch +%Y-%m-%dT%H:%M:%SZ`

	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "/Library/Application Support/JAMF/.userdelay.plist"
	echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "<plist version=\"1.0\">" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "<dict>" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "	<key>$policyID</key>" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "	<date>$newTime</date>" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "</dict>" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "</plist>" >> "/Library/Application Support/JAMF/.userdelay.plist"
}

if [[ "$deferCounter" = "3" ]] ; then
	installPrompt
else
	# Prompt for install or defer
	# Even numbers indicate to install now, odd numbers are specific to defer times
	promptA=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -windowPostion ur -title "Notice" -description "System updates must be installed. You may choose which updates to install now, or select an amount of time to defer these updates." -button1 "Defer" -button2 "Install" -showDelayOptions "300, 900, 1800m"`
	if [ $((promptA%2)) -eq 0 ] ; then
		installPrompt
	elif [[ "$promptA" == "3001" ]] ; then
		dtime="300"
		calculateDefer
		incrementDefer
	elif [[ "$promptA" == "9001" ]] ; then
		dtime="900"
		calculateDefer
		incrementDefer
	elif [[ "$promptA" == "18001" ]] ; then
		dtime="1800"
		calculateDefer
		incrementDefer
	fi


fi

_EOF_

chown root "/Library/Application Support/JAMF/.deferCounter"
chown root "/Library/Application Support/JAMF/.userdelay.plist"