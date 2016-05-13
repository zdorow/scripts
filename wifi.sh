#!/bin/bash

ssid="jamfsoftware"
wpa2key="jamf1234"

sudotest=`whoami | grep root`
if [ "$sudotest" == "root" ]
then
	echo networksetup -addpreferredwirelessnetworkatindex en1 $ssid 0 WPA2 $ssid
	security add-generic-password -a $ssid -D "AirPort network password" -w $wpa2key -s password -U
else
	echo This script must be run as superuser.
fi
