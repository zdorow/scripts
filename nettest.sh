#!/bin/bash

server=`echo nickmavserve.local`

# See if we can connect to the server
if ping -c 1 $server
then
	# Resolve the hostname to it's IP with ping, then prepend the address with bsdp://, because netboot doesn't play nice with hostnames
	resolvenetboot=`ping -c 1 $server | awk -v server="$server" 'match($0, server) {print $3 ; exit}' | sed 's/(/bsdp:\/\//' | sed 's/)://'`
	echo $server resolved to $resolvenetboot, blessing system
	sleep 1
	# Tell the system to boot from the server
#	bless --netboot --server $resolvenetboot
	echo Attempting to netboot to $server...
	sleep 3
	# Pray
#	reboot
else
	echo Unable to connect to $server, exiting.
fi
