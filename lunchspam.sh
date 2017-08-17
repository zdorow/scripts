#!/bin/bash

#
# Script to spam someone over hipchat with lunch suggestions from lunch.sh
#

user="tyler.bauer"
secret="U2FsdGVkX1++Zyb7Ut+2QQ0DlDVONAkx4fJtHyttwXk3M3bwpjxh7GkDhM/Dcu97sZAjd4E6kF2nHbgqLSuPnA=="
salt="14f1da73fa579b66"

function decryptstring() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
    local id_rsa=$(cat ~/.ssh/id_rsa)
    echo "${secret}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${salt}|" -k "${id_rsa}"
}

apitoken=`decryptstring`
function lunch {
	message=`/bin/bash /Users/nickanderson/Documents/lunch.sh dine`
}

while true
do
lunch
curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"html\", \"message\": \"$message\" }" https://api.hipchat.com/v2/user/${user}@jamf.com/message?auth_token=$apitoken
sleep 15
done
