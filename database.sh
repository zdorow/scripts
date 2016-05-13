# Created Lois Fredrickson 8-16-14
#
# Creates a file called /tmp/jamf.tables 
/usr/local/mysql/bin/mysql -ujamfsoftware -pjamfsw03 jamfsoftware -e 'show tables;' | awk '{print $1 }' > /tmp/jamf.tables

count=0

#This loop checks the tables
while read table
   do
    count=$((count+1))
    echo "$count $table"
    #Checks table
    /usr/local/mysql/bin/mysqlcheck -u jamfsoftware -pjamfsw03 jamfsoftware $table 
    #Repair table
    /usr/local/mysql/bin/mysqlcheck -u jamfsoftware -pjamfsw03 --repair jamfsoftware $table 
    #Optimize table
    /usr/local/mysql/bin/mysqlcheck -u jamfsoftware -pjamfsw03 --optimize jamfsoftware $table 
   done < /tmp/jamf.tables

rm /tmp/jamf.tables

exit 0