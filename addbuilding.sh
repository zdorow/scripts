#!/bin/bash



read -p "JSS URL: " server
read -p "JSS Username: " username
read -s -p "JSS Password: " password
echo "" # secret flag fails to newline
read -p "New Building Name: " newbuildingname

touch ~/newbuilding.xml
echo "<building>" > ~/$newbuildingname.xml
echo "<name>$newbuildingname</name>" >> ~/$newbuildingname.xml
echo "</building>" >> ~/$newbuildingname.xml

curl -k -u $username:$password $server/JSSResource/buildings/name/$newbuildingname -T "$HOME/$newbuildingname.xml" -X POST
# curl -k -v -u $username:$password $server/JSSResource/buildings | tidy -xml -utf8 -i

rm ~/$newbuildingname.xml
