#!/bin/bash -x
mkdir /Library/Scripts/EDU
touch /Library/Scripts/EDU/MSRDC.sh
/bin/cat /Library/Scripts/EDUC/MSRDC.sh <<EOF
    #!/bin/bash
    # Joshua D. Miller - July 18, 2014
    # This script will determine if the what's new dialog
    # will display on first run of Microsoft's RDP and turn
    # it off!
     
    Containers="/Users/$USER/Library/Containers"
    Preferences="Data/Library/Preferences"
    RDC="com.microsoft.rdc.mac"
    Version=`/usr/bin/defaults read "/Applications/Microsoft Remote Desktop.app/Contents/Info.plist" CFBundleShortVersionString`
     
    /bin/test -d $Containers/$RDC || /bin/mkdir -p $Containers/$RDC/$Preferences
    /usr/bin/defaults read $Containers/$RDC/$Preferences/$RDC show_whats_new_dialog | /usr/bin/grep "0" || /usr/bin/defaults write $Containers/$RDC/$Preferences/$RDC show_whats_new_dialog -bool False
    /usr/bin/defaults read $Containers/$RDC/$Preferences/$RDC stored_version_number | /usr/bin/grep "$Version" || /usr/bin/defaults write $Containers/$RDC/$Preferences/$RDC stored_version_number $Version
EOF


