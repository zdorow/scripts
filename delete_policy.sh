#!/bin/bash
#read -p "JSS URL (HTTPS Only): " server
#read -p "JSS Username: " username
#read -s -p "JSS Password: " password
#echo ""
read -p "Policy ID to Delete: " policyid

server="https://jss.connectcharter.ca:8443"
username=""
password=""

curl -v -k -u $username:$password $server/JSSResource/policies/id/$policyid -X DELETE

exit 0
