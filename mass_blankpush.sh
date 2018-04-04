#!/bin/bash

ID="4" #ID of Group we want to send commands to
JSS="https://12.jamf.ninja" #Please input your Jamf Pro URL, and include port if applicable
user="admin" #Jamf Pro user account
pass="jamf1234" #password for the above account

# Get list of device IDs
idlist=$(curl -sku $user:$pass $JSS/JSSResource/mobiledevicegroups/id/$ID | xpath //mobile_device_group/mobile_devices/mobile_device/id | grep -Eo '[0-9]{1,4}' | tr '\n' ',')

# Submit list of device IDs for command via API
curl -sku $user:$pass $JSS/JSSResource/mobiledevicecommands/command/BlankPush/id/"$idlist" -X POST
