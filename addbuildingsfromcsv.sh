#!/bin/bash -x

#Declare variables
server=""							#Server name
username=""							#JSS username with API privileges
password=""							#Password for the JSS account
file="tbuildings.csv"		#Path to CSV

#Do not modify below this line

#Variables used to create the XML
a="<building><name>"
b="</name></building>"

#Count the number of entries in the file so we know how many buildings to submit
count=`cat ${file} | awk -F, '{print NF}'`

#Set a variable to start counting how many buildings we've submitted
index="0"

#Loop through the building names and submit to the JSS until we've reached the end of the CSV
while [ $index -lt ${count} ] 
do
	#Increment our counter by 1 for each execution
	index=$[$index+1]
	
	#Set a variable to read the next entry in the CSV
	var=`cat ${file} | awk -F, '{print $'"${index}"'}'`
	touch /tmp/test.xml
	#Output the data and XML to a file
	echo "${var}" > /tmp/test.xml
	
	#Submit the data to the JSS via the API
	curl -k -v -u ${username}:${password} https://${server}:8443/JSSResource/buildings/name/Name -T "/tmp/test.xml" -X POST
done

#Clean up the temporary XML file
# rm /tmp/test.xml

exit 0
