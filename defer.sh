#!/bin/bash +x

# identify the logged in user

# create the defer counter and set it to user ownership temporarily
touch "/Library/Application Support/JAMF/.deferCounter"
chown $consoleuser "/Library/Application Support/JAMF/.deferCounter"
chown $consoleuser "/Library/Application Support/JAMF/.userdelay.plist"

deferCounter=`cat "/Library/Application Support/JAMF/.deferCounter"`

# echo $deferCounter # for debugging
# If we hit the defer limit (3), we're forcing updates to install
if [[ "$deferCounter" = 3 ]] ; then
	rm "/Library/Application Support/JAMF/.deferCounter"
	jamf policy -id 5
fi

# go into user-level so that we have the ability to prompt them with dialogs, then set some things a second time in case we lose variables from rootland
su $consoleuser << '_EOF_'
policyID="345"
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

# if we want to skip the prompt and go straight to installing updates, comment out the other installPrompt for this one instead
#function installPrompt {
#	jamf policy -id 5
#}

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
	echo "<key>$policyID</key>" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "<date>$newTime</date>" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "</dict>" >> "/Library/Application Support/JAMF/.userdelay.plist"
	echo "</plist>" >> "/Library/Application Support/JAMF/.userdelay.plist"
}

# Prompt for install or defer
# Even numbers indicate button2, odd numbers indicate button1
promptA=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -windowPostion ur -title "Notice" -description "System updates must be installed. You may choose which updates to install now, or select an amount of time to defer these updates. You may defer this prompt a maximum of three times before software updates will automatically install." -button1 "Install" -button2 "Defer" -showDelayOptions "300, 900, 1800m" -timeout "600" -countdown`
# echo $promptA # for debugging
if [ $((promptA%2)) -eq 1 ] ; then
	installPrompt
elif [[ "$promptA" == "3002" ]] ; then
	dtime="300"
	calculateDefer
	incrementDefer
elif [[ "$promptA" == "9002" ]] ; then
	dtime="900"
	calculateDefer
	incrementDefer
elif [[ "$promptA" == "18002" ]] ; then
	dtime="1800"
	calculateDefer
	incrementDefer
fi

_EOF_

# own our defer counter as root again, so meddling users can't touch it
chown root "/Library/Application Support/JAMF/.deferCounter"
chown root "/Library/Application Support/JAMF/.userdelay.plist"
