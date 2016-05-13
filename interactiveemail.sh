#!/bin/bash -x


jssurl="" # example: https://myserver.org:8443
username="api"
password=""

###############################
# Do not edit below this line #
###############################

# Command to grab the current machine serial number, clean it up, and set it as a variable
serialnumber=`ioreg -l | awk '/IOPlatformSerialNumber/ { print $4;}' | sed 's/"//' | sed 's/"//'`

# Make our temp files
touch /tmp/setemail.xml
touch /tmp/setemail2.xml

# Set our email address by prompting the user for input with applescript
email=`/usr/bin/osascript <<EOT
tell application "System Events"
activate
set email to text returned of (display dialog "Please Input Your Organization Email Address" default answer "" with icon 2)
end tell
EOT`

# Get our current user and location information from the JSS API and copy it into a temp file
curl -k -u $username:$password $jssurl/JSSResource/computers/serialnumber/$serialnumber/subset/location -X GET | tidy -xml -utf8 -i > /tmp/setemail.xml


# Read the temp file from the JSS, edit it with our input from Applescript, and rewrite it to a new temp file
cat /tmp/setemail.xml | sed 's/<email_address>.*<\/email_address>/<email_address \/>/' | sed "s/<email_address \/>/<email_address>$email<\/email_address>/g" > /tmp/setemail2.xml

# Submit our new user and location information to the JSS API from temp file #2 using serial number location
curl -k -u $username:$password $jssurl/JSSResource/computers/serialnumber/$serialnumber/subset/location -T "/tmp/setemail2.xml" -X PUT


# Remove our temporary files (uncomment to put into effect)
# rm /tmp/setemail.xml
# rm /tmp/setemail2.xml
