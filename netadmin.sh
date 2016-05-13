#!/bin/sh

dscl . create /Users/netadmin
dscl . create /Users/netadmin RealName "Network Admin Account"
dscl . passwd /Users/netadmin jamf1234
dscl . create /Users/netadmin UniqueID 499
dscl . create /Users/netadmin PrimaryGroupID 80
dscl . create /Users/netadmin UserShell /bin/bash
dscl . create /Users/netadmin NFSHomeDirectory /Users/netadmin
dscl . append /Groups/admin GroupMembership netadmin

