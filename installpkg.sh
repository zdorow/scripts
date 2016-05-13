#!/bin/bash

# Path to package, including package name (do not use spaces)
pkg="/Adobe_Install.pkg"

# debug mode, 1 on 0 off
debug="0"

# DO NOT EDIT BELOW THIS LINE

log="/tmp/installscript.log"
touch $log
checksuccess=`tail -n 1 $log | grep "success"`

# check some things so we can get more info from the log
if [ "$debug" == 1 ] ; then
time=`date "+%Y-%m-%d %H:%M:%S: "`
echo ----------------------------------------------------------- >> $log
echo $time DEBUG: User: `whoami` >> $log
echo $time DEBUG: Using `file $pkg` >> $log
echo $time DEBUG: Using `ls -lah $pkg` >> $log
echo $time DEBUG: Pre-Loop Users: `users` >> $log
fi

while true
do
people=`who | grep -c .`
time=`date "+%Y-%m-%d %H:%M:%S: "`
if [ "$people" != "0" ] ; then
	time=`date "+%Y-%m-%d %H:%M:%S: "`
	if [ "$debug" == 1 ] ; then
	echo $time DEBUG: Begin-Install Users: `users` >> $log
	fi
	echo $time Beginning installation of $pkg... >> $log
	installer -pkg $pkg -target / >> $log
	wait
	checksuccess=`tail -n 1 $log | grep "success"`
	if [ "$checksuccess" != "" ] ; then
		echo $time Success! >> $log
		# Remove our firstrun (workaround for reboot during imaging time)
		rm -rf '/Library/Application Support/JAMF/FirstRun/PostInstall/'
		rm /Library/LaunchDaemons/com.jamfsoftware.firstrun.postinstall.plist
		rm /Library/LaunchDaemons/com.jamfsoftware.firstrun.installpkg.plist
		# Remove our package
		rm $pkg
	else
		echo $time Failed to install $pkg. >> $log
	fi
	break
else
	echo $time Waiting... >> $log
	if [ "$debug" == 1 ] ; then
	echo $time DEBUG: Waiting Users: `users` >> $log
	fi
	sleep 15
fi

done
