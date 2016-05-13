#!/bin/bash

address="192.168.1.165"
port="8060"

while [[ "$i" != "#" ]] ; do
	read -d'' -s -n1 i
	if [[ "$i" == "" ]] ; then
		wget -q -O - --post-data "" "http://192.168.1.165:8060/keypress/Lit_ "
	else
		translate=`python -c "import urllib, sys; print urllib.quote(sys.argv[1])" ${i}`
		if [[ "$translate" == "%7F" ]] ; then
			curl -d '' "http://$address:$port/keypress/Backspace"
		else
			curl -d '' "http://$address:$port/keypress/Lit_${translate}"
		fi
	fi
	done