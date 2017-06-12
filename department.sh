#!/bin/bash

###################################################################
#                                                                 #
#   Script to copy department information into an extension       #
#   attribute for St. Stephen's and St. Agnes School              #
#                                                                 #
#   1.0 - Nick Anderson, June 9 2017, Jamf                        #
#                                                                 #
###################################################################

jssurl="https://12.jamf.ninja"
jssuser="admin"
jsspassword="jamf1234"

index="0"
devices=()

idlist=`curl -k -u $jssuser:$jsspassword ${jssurl}/JSSResource/mobiledevices -X GET`
size=`echo $idlist | xpath //mobile_devices/size | sed 's/<[^>]*>//g'`

while [ $index -lt ${size} ] ; do
	index=$[index+1]
	devices+=(`echo $idlist | xpath //mobile_devices/mobile_device[${index}]/id | sed 's/<[^>]*>//g'`)
done

echo ${devices[@]}

for i in "${devices[@]}" ; do
	echo "Working on ${i}"
	inventory=`curl -s -k -u $jssuser:$jsspassword ${jssurl}/JSSResource/mobiledevices/id/${i}/subset/location -X GET`
	department=`echo $inventory | xpath //mobile_device/location/department | sed 's/<[^>]*>//g'`
	echo Device ID ${i} is in department $department

	submitxml="<mobile_device><extension_attributes><extension_attribute><name>Department Test</name><value>$department</value></extension_attribute></extension_attributes></mobile_device>"
	echo Submitting XML content for device ${i}: $submitxml

	curl -s -k -u $jssuser:$jsspassword -H "Content-Type: text/xml" ${jssurl}/JSSResource/mobiledevices/id/${i}/subset/extension_attributes -d "$submitxml" -X PUT
done