#!/bin/bash

####################################################################################################
#
# Copyright (c) 2014, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
#       This script will take apps from VPP and add them to Mobile Device Apps
#      
####################################################################################################
echo "Example: https://jss.example.com:8443"
read -p "JSS Address: " serverName
read -p "JSS Username: " username
read -p "JSS Password: " password
read -p "Path to MySQL binary [/usr/local/mysql/bin/mysql]: " sqlpath
sqlpath=${sqlpath:-/usr/local/mysql/bin/mysql}
read -p "MySQL User [root]: " mysqlUsername
mysqlUsername=${mysqlUsername:-root}


#serverName="https://nup-dc3.quick.jamfsw.corp:8443"
#username="fbi" # JSS Username
#password="fbi" # JSS Password
#mysqlUsername="root" #mysql username
adam_id_file="/tmp/adam_id.txt" # path to that will contain all adam_id, this will be a temp file
temp="/tmp/api.xml" # file create to upload to api
#appinfo="/tmp/app.json" # s

#Connect to MySQL to get a list of Adam ID's for VPP Apps
touch $adam_id_file
$sqlpath -u $mysqlUsername -p jamfsoftware -e "select adam_id from vpp_mobile_device_app_license_app;" | sed -e 's/adam_id//' > $adam_id_file




# pull ADAM ID from xml
while read adamid
do
if [[ "$adamid" == "" ]]; then
echo "empty adam ID"
else

#Curl Apple's API to get information on the apps
curl http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsLookup?id=$adamid | python -mjson.tool | tr -d "\","> /tmp/$adamid.json

displayname=`tail -n 20 /tmp/$adamid.json | grep trackName | sed 's/trackName://'`
echo "display name = $displayname"

description=`head -n 20 /tmp/$adamid.json | grep description | sed 's/description://'`
echo "description = $description"

bundleid=`head -n 16 /tmp/$adamid.json | grep bundleId | sed 's/bundleId://' | tr -d " "`
echo "bundle ID = $bundleid"

version=`tail -n 10 /tmp/$adamid.json | grep version | sed 's/version://'`
echo "version = $version"

appurl=`tail -n 20 /tmp/$adamid.json | grep trackViewUrl | sed 's/trackViewUrl://' | sed 's/&.*//'`
echo "URL = $appurl"

#Create xml file to upload to JSS API
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $temp
echo "<mobile_device_application>?" >> $temp
echo "<general>" >> $temp
echo "<id>6</id>" >> $temp
echo "<name>$displayname</name>" >> $temp
echo "<display_name>$displayname</display_name>" >> $temp
echo "<description/>" >> $temp
echo "<bundle_id>$bundleid</bundle_id>" >> $temp
echo "<version>$version</version>" >> $temp
echo "<internal_app>true</internal_app>" >> $temp
echo "<category>" >> $temp
echo "<id>-1</id>" >> $temp
echo "<name>No category assigned</name>" >> $temp
echo "</category>" >> $temp
echo "<ipa>" >> $temp
echo "<name/>" >> $temp
echo "<uri/>" >> $temp
echo "<data/>" >> $temp
echo "</ipa>" >> $temp
echo "<icon/>" >> $temp
echo "<mobile_device_provisioning_profile/>" >> $temp
echo "<url deprecated=\"9.4\"/>" >> $temp
echo "<itunes_store_url>$appurl</itunes_store_url>" >> $temp
echo "<deployment_type>Install Automatically/Prompt Users to Install</deployment_type>" >> $temp
echo "<deploy_automatically>false</deploy_automatically>" >> $temp
echo "<deploy_as_managed_app>true</deploy_as_managed_app>" >> $temp
echo "<remove_app_when_mdm_profile_is_removed>false</remove_app_when_mdm_profile_is_removed>" >> $temp
echo "<prevent_backup_of_app_data>false</prevent_backup_of_app_data>" >> $temp
echo "<free>false</free>" >> $temp
echo "<host_externally>false</host_externally>" >> $temp
echo "<external_url/>" >> $temp
echo "<site>" >> $temp
echo "<id>-1</id>" >> $temp
echo "<name>None</name>" >> $temp
echo "</site>" >> $temp
echo "</general>" >> $temp
echo "<scope>" >> $temp
echo "<all_mobile_devices>false</all_mobile_devices>" >> $temp
echo "<mobile_devices/>" >> $temp
echo "<mobile_device_groups/>" >> $temp
echo "<buildings/>" >> $temp
echo "<departments/>" >> $temp
echo "<limit_to_users>" >> $temp
echo "<user_groups/>" >> $temp
echo "</limit_to_users>" >> $temp
echo "<network_limitations>" >> $temp
echo "<any_ip_address>true</any_ip_address>" >> $temp
echo "<network_segments/>" >> $temp
echo "</network_limitations>" >> $temp
echo "<limitations>" >> $temp
echo "<users/>" >> $temp
echo "<user_groups/>" >> $temp
echo "<network_segments/>" >> $temp
echo "</limitations>" >> $temp
echo "<exclusions>" >> $temp
echo "<mobile_devices/>" >> $temp
echo "<mobile_device_groups/>" >> $temp
echo "<buildings/>" >> $temp
echo "<departments/>" >> $temp
echo "<users/>" >> $temp
echo "<user_groups/>" >> $temp
echo "<network_segments/>" >> $temp
echo "</exclusions>" >> $temp
echo "</scope>" >> $temp
echo "<self_service>" >> $temp
echo "<self_service_description/>" >> $temp
echo "<self_service_icon/>" >> $temp
echo "</self_service>" >> $temp
echo "</mobile_device_application>" >> $temp


# submit to jss
curl -v -k -u $username:$password $serverName/JSSResource/mobiledeviceapplications/id/0 -T "$temp" -X POST
rm /tmp/$adamid.json
fi
# end loop here
done < $adam_id_file

#Remove the temp files
rm $temp
rm $adam_id_file
