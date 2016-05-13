#!/bin/sh
# Define the variable of the SSID we want to be GOOD here
goodSSID="JAMF Software"

# Get the computer's current SSID
SSID=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I\
| grep ' SSID:' | cut -d ':' -f 2 | tr -d ' '`

# Find the ALL network hardware ports (hwports)
hwports=`networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/,/Ethernet/' | awk 'NR==2' | cut -d " " -f 2`

# Get the wireless network (wirelessnw)
wirelessnw=`networksetup -getairportnetwork $hwports | cut -d " " -f 4`


if [ "$SSID" != "$goodSSID" ]; then
# turn wireless hardware port off
/usr/sbin/networksetup -setairportpower $hwports off
# turn wireless hardware port on
/usr/sbin/networksetup -setairportpower $hwports on
else
exit 0
fi
exit 0