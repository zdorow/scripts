if [ -a /Library/Application\ Support/Twocanoes/Boot\ Runner/bootrunnerstats.plist ]; then
echo "<result>"`defaults read /Library/Application\ Support/Twocanoes/Boot\ Runner/bootrunnerstats.plist`"</result>"
else
echo "<result>Does not exist</result>"
fi 
