#!/bin/bash
#
########################################################################################################
#
# Copyright (c) 2014, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
#
# DESCRIPTION
#
#	This script overwrites group exclusions for mobile device applications, changing
#	all group exclusion items to one specific mobile device group. It will not overwrite other
#	exclusion types.
#
####################################################################################################
#
# HISTORY
#
#	Version 1.0
#  	Created by Nick Anderson, JAMF Software, LLC, on November 24, 2015
#
####################################################################################################

if [ -z "$1" ] ; then
	# Prompt the user for information to connect to the JSS with
	read -p "JSS URL: " jssurl
	read -p "JSS Username: " jssuser
	read -s -p "JSS Password: " jsspassword
	echo ""
	read -p "Group ID: " groupid
else
	# Quick testing credentials, run the script as ./tshirt_api_2.sh bananachameleontomato1234 to use this mode
	jssurl="https://jss.jamfsoftware.us"
	jssuser="api"
	jsspassword=""
	groupid="1"
fi

####################################################################################################
#	Do not edit below this line
####################################################################################################


# Set a counter for our 'for' to start at the beginning
index="0"
# Create an array for apps
apps=()

# Get all of the app records
IDs=`curl -k -u $jssuser:$jsspassword -H "Accept: application/xml" ${jssurl}/JSSResource/mobiledeviceapplications -X GET`
# Record the number of apps to be put into the array from the returned XML
size=`echo $IDs | xpath //mobile_device_applications/size | sed 's/<[^>]*>//g'`

echo $size

# Sort the appr IDs into an array (using the start point of index=0 and the size variable as the end point)
while [ $index -lt ${size} ]
do
	index=$[index+1]
	apps+=(`echo $IDs | xpath //mobile_device_applications/mobile_device_application[${index}]/id | sed 's/<[^>]*>//g'`)
	echo "Adding app ID ${index} to the JSS"
done

# Make a function, because you can't spell function without fun!
function submit {
	# It's important that we set the variable every time we run the curl command, otherwise it will only update the first time it's run
	submitxml="<mobile_device_application><scope><exclusions><mobile_device_groups><mobile_device_group><id>$groupid</id></mobile_device_group></mobile_device_groups></exclusions></scope></mobile_device_application>"
	# Send it!
	curl -s -k -u $jssuser:$jsspassword -H "Content-Type: text/xml" ${jssurl}/JSSResource/mobiledeviceapplications/id/${i} -d "$submitxml" -X PUT
}

for i in "${apps[@]}"
do
	echo "Sending app ID ${i} to the JSS"
	submit
done

