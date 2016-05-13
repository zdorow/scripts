#!/bin/bash -x
w -h | sort -u -t' ' -k1,1 | while read user etc
do
homedir=$(dscl . -read /Users/$user NFSHomeDirectory | cut -d' ' -f2)
echo sudo jamf setComputerName -name $user
# echo $computername
# dscacheutil -flushcache
done
