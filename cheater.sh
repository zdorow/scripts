#!/bin/bash -x
# Just for fun...
sqlserver="dVz-vBd.quick.jamfsw.corp"
apitoken=""
type="room"
recipient="Buntmk5"
color="green"
user="NickAnderson"

# Todo: there's a better way to do this
room=`echo $recipient | sed 's/ /%20/' | sed 's/ /%20/'`

curl -H "Content-Type: application/json" -X GET "https://api.hipchat.com/v2/room/$room/history/latest?max-results=1&auth_token=$apitoken" | python -m json.tool | tr -d '"' | tr -d ' ' > /tmp/latest.json

latestuser=`cat /tmp/latest.json | grep mention_name: | tr -d ','`
latestmessage=`cat /tmp/latest.json | grep message:`

# Check to make sure that we are attempting to use a command before running through our tests
if [[ "$latestmessage" =~ message:!.* ]] ; then
#------

	# !help -- tell us what commands we can use
	if [[ "$latestmessage" = "message:!help" ]] ; then
		if [[ "$latestuser" = "mention_name:$user" ]] ; then
			help="!tomcat -- is tomcat running? <br>!mysql -- is mysql running? <br>!report -- are my servers running? <br>!lastlog -- what's the last thing the JSS said? <br>!sendlog -- what are all the things the JSS said? <br>!tomcatrestart -- restart tomcat <br>!mysqlrestart -- restart mysql <br>!stats -- show room stats"
	                curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"html\", \"message\": \"$help\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
			exit 0
		else
	                curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"You have no power here.\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
			exit 0

		fi
	fi

	# !tomcat -- check to see if tomcat is running on the Ubuntu node
	if [[ "$latestmessage" = "message:!tomcat" && "$latestuser" = "mention_name:$user" ]] ; then
		checktomcat=`service jamf.tomcat7 status`
		curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"$checktomcat\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
		exit 0
	fi

	# !mysql -- check to see if mysql is running on our remote sql server
	if [[ "$latestmessage" = "message:!mysql" && "$latestuser" = "mention_name:$user" ]] ; then
		checkmysql=`ssh root@$sqlserver "service mysql status"`
	     	curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"$checkmysql\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
		exit 0
	fi

	# !report -- generate a report of our three servers and submit them into chat
	if [[ "$latestmessage" = "message:!report" && "$latestuser" = "mention_name:$user" ]] ; then
	        sh /home/nickanderson/healthreport.sh
		healthreport=`cat /tmp/healthreport.txt | sed ':a;N;$!ba;s/\n/\<br\>/g'`
	        curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"html\", \"message\": \"$healthreport\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
	        exit 0
	fi

	# !lastlog -- send the last line of the jamfsoftwareserver.log into chat
	if [[ "$latestmessage" = "message:!lastlog" && "$latestuser" = "mention_name:$user" ]] ; then
		message=`tail -1 /usr/local/jss/logs/JAMFSoftwareServer.log | sed 's/"//g' | tr -d '[]():\n' `
		curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"$message\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
		exit 0
	fi

	# !sendlog -- email the latest jamfsoftwareserver.log to the specified address
	if [[ "$latestmessage" = "message:!sendlog" && "$latestuser" = "mention_name:$user" ]] ; then
	        curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"Sending the JSS Log...\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
		rm /tmp/JAMFSoftwareServer.zip
		zip /tmp/JAMFSoftwareServer.zip /usr/local/jss/logs/JAMFSoftwareServer.log
		echo "Attached is the JAMF Software Server log in a compressed zip archive." | mutt -a "/tmp/JAMFSoftwareServer.zip" -s "JSS Log" -- nick.anderson@jamfsoftware.com
		exit 0
	fi

	# !tomcatrestart -- self explanatory
	if [[ "$latestmessage" = "message:!tomcatrestart" && "$latestuser" = "mention_name:$user"  ]] ; then
		service jamf.tomcat7 restart
		curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"Restarting Tomcat Service...\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
		exit 0
	fi

	# !mysqlrestart -- self explanatory
	if [[ "$latestmessage" = "message:!mysqlrestart" && "$latestuser" = "mention_name:$user"  ]] ; then
	        ssh root@$sqlserver "/etc/init.d/mysql restart"
	        curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"Restarting MySQL Service...\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
		exit 0
	fi

	# !stats -- report the message statistics of the room (nondestructive connection test for when things seem to be failing)
	if [[ "$latestmessage" = "message:!stats" && "$latestuser" = "mention_name:$user"  ]] ; then
		messages=`curl -H "Content-Type: application/json" -X GET "https://api.hipchat.com/v2/room/$room/statistics?auth_token=$apitoken" | python -m json.tool | grep messages_sent | tr -d '"' | tr -d ' ' | sed 's/messages_sent:/Messages Sent: /'`
		users=`curl -H "Content-Type: application/json" -X GET "https://api.hipchat.com/v2/room/$room/member?auth_token=$apitoken" | python -m json.tool | grep mention_name | wc -l`
	        curl -H "Content-Type: application/json" -X POST -d "{ \"message_format\": \"text\", \"message\": \"$messages, Total Users: $users\", \"color\": \"$color\" }" https://api.hipchat.com/v2/room/$room/notification?auth_token=$apitoken
		exit 0
	fi

#------
else
# echo "No commands found, exiting"
exit 0
fi
#------

exit 0

