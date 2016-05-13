#!/bin/bash
#Freddie Cox for Knox County Schools
#Edited by Justin Ellis
#2012

ComputerName=`/usr/bin/osascript <<EOT
tell application "System Events"
activate
set ComputerName to text returned of (display dialog "Please Input New Computer Name" default answer "" with icon 2)
end tell
EOT`

#Set New Computer Name
echo $ComputerName
scutil --set HostName $ComputerName
scutil --set LocalHostName $ComputerName
scutil --set ComputerName $ComputerName

echo Rename Successful
