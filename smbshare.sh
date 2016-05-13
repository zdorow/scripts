#!/bin/bash

#Creates the accounts to be used for the different services
if [ "$(getent passwd smbuser)" ]; then
    echo "smbuser already exists"
else
useradd -d /dev/null -s /dev/null smbuser >> $logFile
echo smbuser:smbuser1 | chpasswd
(echo smbuser1; echo smbuser1) | smbpasswd -s -a smbuser
fi

#Needs normal user creation for AFP mount to work proper
if [ ! -d "/home/afpuser/" ]; then
    mkdir /home/afpuser
fi
if [ "$(getent passwd afpuser)" ]; then
    echo "afpuser already exists"
else
    useradd afpuser -d /home/afpuser >> $logFile
    echo afpuser:afpuser1 | chpasswd
    chown afpuser:afpuser /home/afpuser/ >> $logFile
fi

#Change SMB setting for guest access
sed -i "s/map to guest = bad user/map to guest = never/g" /etc/samba/smb.conf

#Change SMB settings to allow for a symlink in an app or pkg
if ! grep -q 'unix extensions' /etc/samba/smb.conf ; then
sed -i '/\[global\]/ a\
unix extensions = no' /etc/samba/smb.conf
fi

#Create the SMB share for NetBoot
if ! grep -q '\[NetBoot\]' /etc/samba/smb.conf ; then
printf '

\t[NetBoot]
\tcomment = NetBoot
\tpath = /srv/NetBoot/NetBootSP0
\tbrowseable = no
\tguest ok = no
\tread only = yes
\tcreate mask = 0755
\twrite list = smbuser
\tvalid users = smbuser' >> /etc/samba/smb.conf
fi

chown smbuser /srv/NetBoot/NetBootSP0/

#Make the afpuser the owner of the NetBootClients share
chown afpuser /srv/NetBootClients/ >> $logFile

logEvent "OK"

logEvent "Finished deploying NetBoot"

exit 0
