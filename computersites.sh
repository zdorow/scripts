#!/bin/bash

user="admin"
pass="kndawher"
url="https://nickcce.local"

# set counter
index="0"
# create an array
computers=()
# acquire IDs of all computers
computerIDs=`curl -k -u $user:$pass ${url}/JSSResource/computers -X GET`
# determine number of computers in list
quantity=`echo $computerIDs | xpath //computers/size | sed 's/<[^>]*>//g'`
echo "$quantity computers to sort through."
# sort the computer IDs into an array
while [ $index -lt ${quantity} ] 
do
	index=$[index+1]
	computers+=(`echo $computerIDs | xpath //computers/computer[${index}]/id | sed 's/<[^>]*>//g'`)
done
# work on the computers
for i in "${computers[@]}"
do
	# announce which computer we're working on
	echo "Computer ID ${i}"
	# grab the current list of sites associated with the computer
	site=`curl -k -u $user:$pass ${url}/JSSResource/computers/id/${i}/subset/general -X GET | xpath //computer/general/site/name | sed 's/<[^>]*>//g'`
	echo "Current site: $site"
	if [[ "$site" == "None" ]] ; then
		echo "Setting new site ID"
		newXML="<computer><general><site><id>1</id></site></general></computer>"
		curl -k -u $user:$pass -H "Content-Type: text/xml" ${url}/JSSResource/computers/id/${i} -d "$newXML" -X PUT
	fi
done