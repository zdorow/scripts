#!/bin/bash

# Configuration:
jssurl="https://buntmk5.local:8443"
username="api"
password="api"
date=`date +"%m-%d-%y"`
currentimage="10.9.0_Build_2_$date"

# Do not edit below this line

touch /tmp/imagename.xml

cat > /tmp/imagename.xml <<EOF
<computer>
<extension_attributes>
<extension_attribute>
<name>Last Image</name>
<value>$currentimage</value>
</extension_attribute>
</extension_attributes>
</computer>
EOF

serialnumber=`ioreg -l | awk '/IOPlatformSerialNumber/ { print $4;}' | sed 's/"//' | sed 's/"//'`

curl -k -u $username:$password $jssurl/JSSResource/computers/serialnumber/$serialnumber/subset/extension_attributes -T "/tmp/imagename.xml" -X PUT

rm /tmp/imagename.xml
