#!/bin/bash

apitoken=""
read -p "Type [room | private]: " type
read -p "Recipient: " recipient
read -p "Message: " message

room=`echo $recipient | sed 's/ /%20/g'`
echo $room

person=`echo $recipient | sed 's/ /./'`

send=`echo $message | sed 's/ /%20/g'`


if [[ "$type" = "room" ]] ; then
	read -p "Color [ yellow | green | red | purple | gray | random ]: " color
	curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"html\", \"message\": \"$message\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
else
	if [[ "$type" = "private" ]] ; then
		curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"html\", \"message\": \"$message\" }" https://api.hipchat.com/v2/user/$person@jamfsoftware.com/message?auth_token=$apitoken
	else
		echo "Type invalid"
	fi
fi
