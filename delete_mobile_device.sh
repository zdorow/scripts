#!/bin/bash
read -p "JSS URL (HTTPS Only): " server
read -p "JSS Username: " username
read -s -p "JSS Password: " password
echo ""
read -p "Computer ID to delete: " input
read -p "Are you sure you would like to delete the computer with the ID of $input? [y/n]" yesno

if [[ "$yesno" = "y" ]] ; then
	curl -v -k -u $username:$password $server/JSSResource/mobiledevices/id/$input -X DELETE
fi
echo "Process complete."
