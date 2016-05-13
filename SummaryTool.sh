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
####################################################################################################
#
#	DESCRIPTION
#
#	This script was designed to read full JSS Summaries generated from version 9+.
#	The script will parse through the summary and return back a set of data that
#	should be useful when performing JSS Health Checks.
#
####################################################################################################
# 
#	HISTORY
#
#	Version 1.0 Created by Sam Fortuna on June 13th, 2014
#	Version 1.1 Updated by Sam Fortuna on June 17th, 2014
#		-Fixed issues with parsing some data types
#		-Added comments for readability
#		-Added output about check-in information
#		-Added database size parsing
#
#	Version 1.2 Updated by Nick Anderson August 4, 2014
#		-Added recommendations to some displayed items
#	Version 1.3 Updated by Nick Anderson on October 14, 2014
#		-Fixed the way echo works in some terminals
#	TODO in version 1.4
#		-Implement a scaling system fitted to individual preference
#		-Re-order items to match most common workflows
#		-Recommend minimum tomcat memory (cannot read from summary)
#
####################################################################################################

#Enter the path to the JSS Summary (cannot includes spaces)

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

# check to see what kind of terminal this is to make sure we use the right echo mode, no idea why some are different in this aspect
echotest=`echo -e "test"`
if [[ "$echotest" == "test" ]] ; then
	echomode="-e"
else
	echomode=""
fi


#Gathers smaller chunks of the whole summary to make parsing easier

#Get the first 75 lines of the Summary
basicInfo=`head -n 75 $file`
#Find the line number that includes clustering information
lineNum=`cat $file | grep -n "Clustering Enabled" | awk -F : '{print $1}'`
#Store 100 lines after clustering information
subInfo=`head -n $(($lineNum + 100)) $file | tail -n 101`
#Find the line number for the push certificate Subject (used to get the expiration)
pushExpiration=`echo "$subInfo" | grep -n "com.apple.mgmt" | awk -F : '{print $1}'`
#Find the line number that includes checkin frequency information
lineNum=`cat $file | grep -n "Check-in Frequency" | awk -F : '{print $1}'`
#Store 30 lines after the Check-in Frequency information begins
checkInInfo=`head -n $(($lineNum + 30)) $file | tail -n 31`
#Store last 300 lines to check database table sizes
dbInfo=`tail -n 300 $file`


# Add up the number of devices we have
computers=`echo "$basicInfo" | awk '/Managed Computers/ {print $NF}'`
mobiles=`echo "$basicInfo" | awk '/Managed Mobile Devices/ {print $NF}'`
totaldevices="$(( $computers + $mobiles ))"

# Sort our summary into a performance bracket
if (( $totaldevices < 301 )) ; then
	echo "Bracket shown for 1-300 Devices"
	poolsizerec="150"
	sqlconnectionsrec="151"
	httpthreadsrec="453"
	clusterrec="Unnecessary"
	maxpacketrec="512MB"
else
	if (( $totaldevices < 601 )) ; then
		echo "Bracket shown for 301-600 Devices"
		poolsizerec="150"
		sqlconnectionsrec="301"
		httpthreadsrec="753"
		clusterrec="Unnecessary"
		maxpacketrec="512MB"
	else
		if (( $totaldevices < 1001)) ; then
			echo "Bracket shown for 601-1000 Devices"
			poolsizerec="150"
			sqlconnectionsrec="601"
			httpthreadsrec="1503"
			clusterrec="Consider Load Balancing"
			maxpacketrec="1024MB"
		else
			if (( $totaldevices < 2001 )) ; then
				echo "Bracket shown for 1001-2000 Devices"
				poolsizerec="300"
				sqlconnectionsrec="801"
				httpthreadsrec="2003"
				clusterrec="Seriously consider Load Balancing"
				maxpacketrec="1024MB"
			else
				if (( $totaldevices < 5001 )) ; then
					echo "Bracket shown for 2001-5000 Devices"
					poolsizerec="300"
					sqlconnectionsrec="1001"
					httpthreadsrec="2503"
					clusterrec="Load Balancing"
					maxpacketrec="1024MB"
				else
					echo "Bracket shown for > 5000 Devices. SO MANY DEVICES."
					poolsizerec="300 (or more)"
					sqlconnectionsrec="1001 (or more)"
					httpthreadsrec="2503 (or more)"
					clusterrec="Load Balancing"
					maxpacketrec="1024MB"
				fi
			fi
		fi
	fi
fi


#Parse the data and print out the results
echo $echomode "JSS Version: \t\t\t\t $(echo "$basicInfo" | awk '/Installed Version/ {print $NF}')"
echo $echomode "Managed Computers: \t\t\t $(echo "$basicInfo" | awk '/Managed Computers/ {print $NF}')"
echo $echomode "Managed Mobile Devices: \t\t $(echo "$basicInfo" | awk '/Managed Mobile Devices/ {print $NF}')"
echo $echomode "Server OS: \t\t\t\t $(echo "$basicInfo" | grep "Operating System" | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}')"
echo $echomode "Java Version: \t\t\t\t $(echo "$basicInfo" | awk '/Java Version/ {print $NF}')"
echo $echomode "Database Size: \t\t\t\t $(echo "$basicInfo" | grep "Database Size" | awk 'NR==1 {print $(NF-1),$NF}')"
echo $echomode "Maximum Pool Size:  \t\t\t $(echo "$basicInfo" | awk '/Maximum Pool Size/ {print $NF}') \t$(tput setaf 2)Recommended: $poolsizerec$(tput sgr0)"
if [ "$clustering" = "false'" ] ; then
	echo $echomode "Maximum MySQL Connections: \t\t $(echo "$basicInfo" | awk '/max_connections/ {print $NF}') \t$(tput setaf 2)Recommended: $sqlconnectionsrec$(tput sgr0)"
else
	echo $echomode "Maximum MySQL Connections: \t\t $(echo "$basicInfo" | awk '/max_connections/ {print $NF}') \t$(tput setaf 2)Recommended: $sqlconnectionsrec X Number of cluster nodes$(tput sgr0)"
fi

binlogging=`echo "$basicInfo" | awk '/log_bin/ {print $NF}'`
if [ "$binlogging" = "OFF" ] ; then
	echo $echomode "Bin Logging: \t\t\t\t $(echo "$basicInfo" | awk '/log_bin/ {print $NF}')"
else
	echo $echomode "Bin Logging: \t\t\t\t $(echo "$basicInfo" | awk '/log_bin/ {print $NF}') \t$(tput setaf 9)[!]$(tput sgr0)"
fi
echo $echomode "Max Allowed Packet Size: \t\t $(($(echo "$basicInfo" | awk '/max_allowed_packet/ {print $NF}')/ 1048576)) MB \t$(tput setaf 2)Recommended: $maxpacketrec$(tput sgr0)"
echo $echomode "MySQL Version: \t\t\t\t $(echo "$basicInfo" | awk '/version ..................../ {print $NF}')"

clustering=`echo "$subInfo" | awk '/Clustering Enabled/ {print $NF}'`
if [ "$clustering" = "false" ] ; then
	echo $echomode "Clustering Enabled: \t\t\t $(echo "$subInfo" | awk '/Clustering Enabled/ {print $NF}') \t$(tput setaf 2)Recommended: $clusterrec$(tput sgr0)"
else
	echo $echomode "Clustering Enabled: \t\t\t $(echo "$subInfo" | awk '/Clustering Enabled/ {print $NF}') \t$(tput setaf 9)[!]$(tput sgr0)"
fi

changemanagement=`echo "$subInfo" | awk '/Use Log File/ {print $NF}'`
if [ $changemanagement = false ] ; then
	echo $echomode "Change Management Enabled: \t\t $(echo "$subInfo" | awk '/Use Log File/ {print $NF}') \t$(tput setaf 2)Recommended: On$(tput sgr0)"
else
	echo $echomode "Change Management Enabled: \t\t $(echo "$subInfo" | awk '/Use Log File/ {print $NF}') \t$(tput setaf 2)✓$(tput sgr0)"
fi
echo $echomode "Log File Location: \t\t\t $(echo "$subInfo" | awk -F . '/Location of Log File/ {print $NF}')"

sslsubject=`echo "$subInfo" | awk '/SSL Cert Subject/ {$1=$2=$3="";print $0}' | grep "O=JAMF Software"`
if [ "$sslsubject" = "" ] ; then
	echo $echomode "SSL Certificate Subject: \t      $(echo "$subInfo" | awk '/SSL Cert Subject/ {$1=$2=$3="";print $0}') \t$(tput setaf 9)[!]$(tput sgr0)"
else
	echo $echomode "SSL Certificate Subject: \t      $(echo "$subInfo" | awk '/SSL Cert Subject/ {$1=$2=$3="";print $0}')"
fi
echo $echomode "SSL Certificate Expiration: \t\t $(echo "$subInfo" | awk '/SSL Cert Expires/ {print $NF}')"
echo $echomode "HTTP Threads: \t\t\t\t $(echo "$subInfo" | awk '/HTTP Connector/ {print $NF}') \t$(tput setaf 2)Recommended: $httpthreadsrec$(tput sgr0)"
echo $echomode "HTTPS Threads: \t\t\t\t $(echo "$subInfo" | awk '/HTTPS Connector/ {print $NF}') \t$(tput setaf 2)Recommended: $httpthreadsrec$(tput sgr0)"
echo $echomode "JSS URL: \t\t\t\t $(echo "$subInfo" | awk '/HTTPS URL/ {print $NF}')"
echo $echomode "APNS Expiration: \t\t\t $(echo "$subInfo" | grep "Expires" | awk 'NR==3 {print $NF}')"

thirdpartycert=`echo "$subInfo" | awk '/External CA enabled/ {print $NF}'`
if [ $thirdpartycert = false ] ; then
	echo $echomode "External CA Enabled: \t\t\t $(echo "$subInfo" | awk '/External CA enabled/ {print $NF}')"
else
	echo $echomode "External CA Enabled: \t\t\t $(echo "$(tput setaf 3)$subInfo" | awk '/External CA enabled/ {print $NF}') \t$(tput setaf 9)[!]$(tput sgr0)"
fi
echo $echomode "Log Flushing Time: \t\t\t $(echo "$subInfo" | grep "Each Day" | awk '{for (i=7; i<NF; i++) printf $i " "; print $NF}') \t$(tput setaf 2)Recommended: Stagger time from nightly backup$(tput sgr0)"

logflushing=`echo "$subInfo" | awk '/Do not flush/ {print $0}' | wc -l`
if ! (( $logflushing < 1 )) ; then
	echo $echomode "Number of logs set to NOT flush:  $(echo "$subInfo" | awk '/Do not flush/ {print $0}' | wc -l) \t$(tput setaf 2)Recommended: Enable log flushing$(tput sgr0)"
else
	echo $echomode "Number of logs set to NOT flush:  $(echo "$subInfo" | awk '/Do not flush/ {print $0}' | wc -l) \t$(tput setaf 2)✓$(tput sgr0)"
fi

logflushing6months=`echo "$subInfo" | awk '/6 month/ {print $0}' | wc -l`
logflushing1year=`echo "$subInfo" | awk '/1 year/ {print $0}' | wc -l`
notlogflushing3months="$(( $logflushing6months + $logflushing1year + $logflushing ))"

if ! (( $notlogflushing3months < 1 )) ; then
	echo $echomode "Logs not flushing in under 3 months:     $notlogflushing3months \t$(tput setaf 2)Recommended: Shorten log flushing time$(tput sgr0)"
else
	echo $echomode "Logs not flushing in  under 3 months:    $notlogflushing3months \t$(tput setaf 2)✓$(tput sgr0)"
fi


echo $echomode "Check in Frequency: \t\t\t $(echo "$checkInInfo" | awk '/Check-in Frequency/ {print $NF}')"
echo $echomode "Login/Logout Hooks enabled: \t\t $(echo "$checkInInfo" | awk '/Logout Hooks/ {print $NF}')"
echo $echomode "Startup Script enabled: \t\t $(echo "$checkInInfo" | awk '/Startup Script/ {print $NF}')"
echo $echomode "Flush history on re-enroll: \t\t $(echo "$checkInInfo" | awk '/Flush history on re-enroll/ {print $NF}')"
echo $echomode "Flush location info on re-enroll: \t $(echo "$checkInInfo" | awk '/Flush location information on re-enroll/ {print $NF}')"
pushnotifications=`echo "$checkInInfo" | awk '/Push Notifications Enabled/ {print $NF}'`
if [ "$pushnotifications" = "true" ] ; then
	echo $echomode "Push Notifications enabled: \t\t $(echo "$checkInInfo" | awk '/Push Notifications Enabled/ {print $NF}')"
else
	echo $echomode "Push Notifications enabled: \t\t $(echo "$checkInInfo" | awk '/Push Notifications Enabled/ {print $NF}') \t$(tput setaf 9)[!]$(tput sgr0)"
fi


#Check for database tables over 1 GB in size
echo "Tables over 1 GB in size:"
echo "$(echo "$dbInfo" | awk '/GB/ {print $1, "\t", "\t", $(NF-1), $NF}')"

#Find problematic policies that are ongoing, enabled, update inventory and have a scope defined
list=`cat $file| grep -n "Ongoing" | awk -F : '{print $1}'`

echo "The following policies are Ongoing, Enabled and update inventory:"

for i in $list 
do

	#Check if policy is enabled
	test=`head -n $i $file | tail -n 13`
	enabled=`echo "$test" | awk /'Enabled/ {print $NF}'`
	
	#Check if policy has an active trigger
	if [[ "$enabled" == "true" ]]; then
		trigger=`echo "$test" | grep Triggered | awk '/true/ {print $NF}'`
	fi
		
	#Check if the policy updates inventory
	if [[ "$enabled" == "true" ]]; then
		line=$(($i + 35))
		inventory=`head -n $line $file | tail -n 5 | awk '/Update Inventory/ {print $NF}'`
	fi
	
	#Get the scope
	scope=`head -n $(($i + 5)) $file |tail -n 5 | awk '/Scope/ {$1=""; print $0}'`
		
		#Get the name of the policy
		if [[ "$trigger" == "true" && "$inventory" == "true" ]]; then
			name=`echo "$test" | awk -F . '/Name/ {print $NF}'`
			echo "Name: $name" 
			echo "Scope: $scope"
		fi
done


exit 0