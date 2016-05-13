#!/bin/bash

if [ -z "$1" ] ; then
	# Prompt the user for information to connect to the JSS with
	read -p "JSS URL: " jssurl
	read -p "JSS Username: " jssuser
	read -s -p "JSS Password: " jsspassword
	echo ""
else
	# Quick testing credentials, run the script as ./tshirt_api_2.sh bananachameleontomato1234 to use this mode
	jssurl="https://yer-jss.quick.jamfsw.corp:8443"
	jssuser="admin"
	jsspassword="jamf1234"
fi

# Set a counter for our 'for' to start at the beginning
index="0"
# Create an array for computer
computers=()

# Get all of the computer records
IDs=`curl -k -u $jssuser:$jsspassword ${jssurl}/JSSResource/computers -X GET`
# Record the number of computers to be put into the array from the returned XML
size=`echo $IDs | xpath //computers/size | sed 's/<[^>]*>//g'`

# Sort the computer IDs into an array (using the start point of index=0 and the size variable as the end point)
while [ $index -lt ${size} ]
do
	index=$[index+1]
	computers+=(`echo $IDs | xpath //computers/computer[${index}]/id | sed 's/<[^>]*>//g'`)
done

# Make a function, because you can't spell function without fun!
function submit {
	# It's important that we set the $color variable every time we run the curl command, otherwise it will only update the first time it's run
	submitxml="<computer><extension_attributes><extension_attribute><name>TShirt</name><value>$color</value></extension_attribute></extension_attributes></computer>"
	# Send it!
	curl -s -k -u $jssuser:$jsspassword -H "Content-Type: text/xml" ${jssurl}/JSSResource/computers/id/${i}/subset/extension_attributes -d "$submitxml" -X PUT
}

# For each computer in the array, do all of these things
for i in "${computers[@]}"
do
	# Tell the terminal which inventory record we're working on
	echo "$(tput setaf 2)Scanning ${i}$(tput sgr0)"
	# Collect the comprehensive inventory information for the current device we're checking in the array
	computer=`curl -s -k -u $jssuser:$jsspassword ${jssurl}/JSSResource/computers/id/${i} -X GET`
	# Filter the information down to the extension attribute to prevent contamination to our greps
	tshirt=`echo $computer | xpath //computer/extension_attributes/extension_attribute | tidy -xml -utf8 -i | sed 's/<[^>]*>//g' | grep -A 2 TShirt`
	# Echo the extension attribute as many times as there are colors and search for each color -- there is totally a better way to do this
	red=`echo $tshirt | grep Red`
	blue=`echo $tshirt | grep Blue`
	no=`echo $tshirt | grep No`
	if [[ -n "$red" ]] ; then
		# User chose red, mark it as ordered and retain the selection for inventory
		color="Done Red"
		# Call the submit function
		submit
	elif [[ -n "$blue" ]] ; then
		# User chose blue, mark it as ordered and retain the selection for inventory
		color="Done Blue"
		# Call the submit function
		submit
	elif [[ -n "$no" ]] ; then
		# User didn't want a free t-shirt, mark it as ordered and send a pink slip instead
		color="Done None"
		# Call the submit function
		submit
	else
		# Waiting isn't a real color
		color="Waiting"
		# Call the submit function
		submit
	fi
done

