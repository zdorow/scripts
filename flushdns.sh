#!/bin/bash

sudo killall -HUP mDNSResponder
sudo dscacheutil -flushcache
