#!/bin/bash

# ChATfacts

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
}

function decryptstring() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
    local id_rsa=$(cat ~/.ssh/id_rsa)
    echo "${secret}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${salt}|" -k "${id_rsa}"
}

json=`curl -X GET --header 'Accept: application/json' 'https://catfact.ninja/fact'`
prop='fact'
user="$1"
secret="potato=="
salt="1234"
message=`jsonval`
apitoken=`decryptstring`

echo $message
curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"html\", \"message\": \"$message\" }" https://api.hipchat.com/v2/user/${user}@jamf.com/message?auth_token=$apitoken
