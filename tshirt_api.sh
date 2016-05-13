#!/bin/bash

# Values set by user
server="https://nup-dc3.quick.jamfsw.corp:8443"
username="admin"
password="jamf1234"

# Create a list of computer IDs that we can draw from
rm /tmp/computers.xml
curl -k -u $username:$password $server/JSSResource/computers -X GET | tidy -xml -utf8 -i > /tmp/computers.xml
cat /tmp/computers.xml | grep "<id>" | tr -d ' </id>' | tr '\n' ',' > /tmp/computerids.xml

# Count our computers and set the counter to 0
count=`cat /tmp/computerids.xml | awk -F, '{print NF}'`
index="0"
rm /tmp/shirtdata.xml

# Loop through our computer IDs and grab the existing extension attribute data for each of them
while [ $index -lt ${count} ]
do
	index=$[$index+1]
	var=`cat /tmp/computerids.xml | awk -F, '{print $'"${index}"'}'`
	echo $var >> /tmp/shirtdata.xml
	curl -k -u $username:$password $server/JSSResource/computers/id/$var/subset/extension_attributes -X GET | tidy -xml -utf8 -i  | grep -A 3 TShirt >> /tmp/shirtdata.xml
done

# Loop through our computer IDs and submit modified data to the JSS for each of them
index2="0"
while [ $index2 -lt ${count} ]
do
	index2=$[$index2+1]
	var=`cat /tmp/computerids.xml | awk -F, '{print $'"${index2}"'}'`

	newshirt=`cat /tmp/shirtdata.xml | grep -A 3 $var | grep value`

	# If the user picked a shirt color, consider it done, if they didn't, fire them
	if [[ $newshirt =~ .*Red.* ]] ; then
		newvalue="<value>Done</value>"
	elif [[ $newshirt =~ .*Blue.* ]] ; then
		newvalue="<value>Done</value>"
	elif [[ $newshirt =~ .*No.* ]] ; then
		newvalue="<value>Contact User</value>"
	else
		newvalue="<value>API Waiting</value>"
	fi

# Create our XML data for submission to the JSS
cat > /tmp/shirtsubmit.xml <<EOF
<computer>
<extension_attributes>
<extension_attribute>
<name>TShirt</name>
$newvalue
</extension_attribute>
</extension_attributes>
</computer>
EOF
	# Send it!
	curl -k -u $username:$password $server/JSSResource/computers/id/$var/subset/extension_attributes -T "/tmp/shirtsubmit.xml" -X PUT
done