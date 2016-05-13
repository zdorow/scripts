#!/bin/bash

recontest=`sudo jamf recon | grep Submitting`

if [ $? -eq 0 ]
then
	echo "This machine is enrolled."
else
	echo "This machine is not enrolled."
fi
