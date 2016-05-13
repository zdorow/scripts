#!/bin/bash

txt="/tmp/tshirt.txt"
tshirt=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "Free T-Shirt!" -description "Would you like a complimentary T shirt?" -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/HelpIcon.icns -button1 "Yes" -button2 "No"`

rm $txt
touch $txt

function color {
 tshirt=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "Selection" -description "What color T shirt would you like?" -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ProfileBackgroundColor.icns -button1 "Red" -button2 "Blue"`
 if [ $tshirt == 0 ] ; then
 	echo "Red shirt" >> $txt
 elif [ $tshirt == 2 ] ; then
 	echo "Blue Shirt" >> $txt
 fi
}

if [ $tshirt == 0 ] ; then
	 color
	elif [ $tshirt == 2 ] ; then
	    tshirt=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "Selection" -description "You have chosen not to receive a T shirt. You will receive your notice of termination within 24 hours." -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarFavoritesIcon.icns -button1 "Wait!" -button2 "Whatever"`
		if [ $tshirt == 2 ] ; then
			echo "No Shirt" >> $txt
		elif [ $tshirt == 0 ] ; then
			color
		fi

fi

exit 0