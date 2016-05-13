#!/bin/bash

# Check for existence of tables: encryption_key, certificate_authority_settings, and push_notification_keystores.

####### 
#Depending on your OS or a custom MySQL location, you may need to change
#the path. Additionally, as per Company Security guidelines, the database
#should not be named jamfsoftware, so remember to change it here as well,
#as well as the password attached to the -p flag.
#######

mysqlbinary="/usr/local/mysql/bin/mysql" #For OSX 

#mysqlLogin=`$mysqlbinary -u jamfsoftware -pjamfsw03 jamfsoftware`

tableCheck=`$mysqlbinary -u jamfsoftware -pjamfsw03 jamfsoftware -e "show tables" 2>/dev/null`
#certificateAuthorityCheck=`$mysqlbinary -u jamfsoftware -pjamfsw03 jamfsoftware -e "show tables like 'certificate_authority_settings'"`
#pushNotificationCheck=`$mysqlbinary -u jamfsoftware -pjamfsw03 jamfsoftware -e "show tables like 'push_notification_keystores'"`



# If the tables exist we will drop them.
if [[ "$tableCheck" =~ encryption_key ]]
	then
		echo "Dropping Table: encryption_key"
		`$mysqlbinary -u jamfsoftware -pjamfsw03 jamfsoftware -e "drop table encryption_key"`
	else
		echo "Table encryption_key already dropped. Nothing to do."
fi

if [[ "$tableCheck" =~ certificate_authority_settings ]]
	then
		echo "Dropping Table: certificate_authority_settings"
		`$mysqlbinary -u jamfsoftware -pjamfsw03 jamfsoftware -e "drop table certificate_authority_settings"`
	else
		echo "Table certificate_authority_settings already dropped. Nothing to do."
fi

if [[ "$tableCheck" =~ push_notification_keystores ]]
	then
		echo "Dropping Table: push_notification_keystores"
		`$mysqlbinary -u jamfsoftware -pjamfsw03 jamfsoftware -e "drop table push_notification_keystores"`

	else
		echo "Table push_notification_keystores already dropped. Nothing to do."
fi
