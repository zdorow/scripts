#!/bin/bash -x

touch /tmp/userlist.txt
touch /tmp/replacerlist.txt

numberofusers=`dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]' | grep name: | sed 's/name: //' | wc -l | sed '/^&/d;s/[[:blank:]]//g'`
dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]' | grep name: | sed 's/name: //' > /tmp/userlist.txt

function manytimes {
	n=0
	shift
	while [[ $n -lt $numberofusers ]]; do
		$@
		n=$((n+1))
	done
}

manytimes $numberofusers echo $replacer > /tmp/replacerlist.txt

while read users
  do
    count=$((count+1))
	echo "cd /Users/$users/"
	echo "su $users" >> /tmp/replacerlist.txt
	echo "/usr/bin/defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Users/$users/Downloads</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-label</key><string>Downloads</string></dict><key>file-type</key><string>directory-tile</string></dict>'" >> /tmp/replacerlist.txt
	echo "exit" >> /tmp/replacerlist.txt
  done < /tmp/userlist.txt

sh /tmp/replacerlist.txt

# cat /tmp/replacerlist.txt

# rm /tmp/userlist.txt
# rm /tmp/replacerlist.txt
