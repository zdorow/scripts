#!/bin/bash -x
computerid=`scutil --get ComputerName`
dsconfigldap -f -v -a od.jamfsw.corp -c $computerid -u diradmin -p deprecated -v sleep 20
dscl /Search -create / SearchPolicy CSPSearchPath
dscl /Search -append / CSPSearchPath /LDAPv3/od.jamfsw.corp
exit 0
