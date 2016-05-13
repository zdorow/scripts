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
#	This script will check to see if a user has logged in repeatedly, and attempt
#	to install a package when that criteria is met.
#
#	v1.0 -- Nick Anderson on November 24th, 2014
#
####################################################################################################

# Path to package to install (must contain no spaces)
pkg="/Adobe_Install.pkg"

# Remove package after installation? [ yes or no ]
cleanup="no"

# Path for our log file and format for date
log="/tmp/installscript.log"
logtime=`date "+%Y-%m-%d %H:%M:%S: "`

# How many times to try and how long to wait in seconds between tries
counter="60"
waiter="30"

# Create our log file and write the current time to it
touch $log
echo "V----------------------------$logtime----------------------------V" >> $log

# Run our check for logged in users until the counter runs out
until [[ "$counter" -lt 1 ]] ; do
	let counter-=1
	people=`who | grep -c .`
	# If the number of logged in users is not zero, attempt to install, otherwise wait for the set amount of time
	if [[ "$people" != "0" ]] ; then
		installer -pkg $pkg -target / >> $log
		wait
		# After the installer completes, write success to log file and remove package if desired
		checksuccess=`tail -n 1 $log | grep "success"`
			if [[ "$checksuccess" != "" ]] ; then
				echo "Package appears to have installed successfully. Exiting." >> $log
				if [[ "$cleanup" == "yes" ]] ; then
					rm $pkg
				fi
				exit 0
			else
				echo "Package could not install. Exiting with error." >> $log
				exit 1
			fi
	else
		# Tell the log file how long we're going to sleep, and then sleep
		echo "Waiting $waiter seconds $counter more times" >> $log
		sleep $waiter
	fi
done