#!/bin/bash
####################################################################################################
#
# Copyright (c) 2015, JAMF Software, LLC.  All rights reserved.
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
#       EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
#
#		This script injects RemoveApplication commands for the specified 'appid' for
#		all devices that are personally enrolled.
#
#		v1.0 - Nick Anderson, Jamf - May 23 2018
#
####################################################################################################

mysqluser="jamfsoftware"
mysqlpassword="jamfsw03"
database="yamf"
appid="2"

epoch=$(date +"%s")

devices=$(mysql -u jamfsoftware -pjamfsw03 --database yamf -e "select mobile_device_id from mobile_devices_denormalized where is_personal=1\G" | awk '/mobile_device_id:/ {print $NF}')

for i in ${devices}; do
        uuid=$(uuidgen)
        mysql -u $mysqluser -p$mysqlpassword --database $database -e "insert into mobile_device_management_commands (device_id,command,uuid,profile_id,date_sent_epoch,message_id,command_valid_after_epoch,error_english_description,error_localized_description,command_attributes,error_code,inactive,device_object_id) VALUES(${i},\"RemoveApplication\",\"${uuid}\",$appid,${epoch}000,-1,${epoch}000,\"\",\"\",\"\",-1,0,21);"
done
