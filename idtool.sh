#!/bin/bash



read -p "Summary Location: " file
#file="/Users/nickanderson/Desktop/jssSummary-1410804159149.txt "

#Option to read in the path from Terminal
if [[ "$file" == "" ]]; then
	echo "Please enter the path to the JSS Summary file (currently does not support paths with spaces)"
	read file
fi

#Verify we can read the file
data=`cat $file`
if [[ "$data" == "" ]]; then
	echo "Unable to read the file path specified"
	echo "Ensure there are no spaces and that the path is correct"
	exit 1
fi


cat $file | grep "iTunes Store URL" | awk '/iTunes Store URL ........................./ {print $NF}'