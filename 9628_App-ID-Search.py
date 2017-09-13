#!/usr/bin/python

####################################################################################################
#
# Copyright (c) 2016, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#   Author: Robert Haake
#   Last Modified: 10/26/16
#   Version: 1.00
#
#   Description: Takes a list of iTunes store urls and find which apps are still able to be looked
#   up via an iTunes search.
#
#   Usage: python App-ID-Search.py
#
#
####################################################################################################

import json
import httplib
import urllib2
import socket
import ssl
import logging
import re
import csv

######### Create csv of itunes urls from Summary ###########
gk_summary = raw_input('Path to JSS Summary: ')
gk_write_file = '/Users/Shared/itunesurl.csv'
gk_url_file = open(gk_write_file,'wb')
with open (gk_summary.replace('\\','').strip(),'rU') as gk_in_file: 
	for gk_line in gk_in_file:
			gk_url = re.search('http(.+?)itunes.apple.com(.+?)$', gk_line)
			if gk_url:
				gk_url_string = gk_url.group(0) + '\n'
				gk_url_file.write(gk_url_string)
gk_url_file.close()

#######################################

# Force TLS since the JSS now requires TLS+ due to the POODLE vulnerability
class TLS1Connection(httplib.HTTPSConnection):
    def __init__(self, host, **kwargs):
        httplib.HTTPSConnection.__init__(self, host, **kwargs)

    def connect(self):
        sock = socket.create_connection((self.host, self.port), self.timeout, self.source_address)
        if getattr(self, '_tunnel_host', None):
            self.sock = sock
            self._tunnel()

        self.sock = ssl.wrap_socket(sock, self.key_file, self.cert_file, ssl_version=ssl.PROTOCOL_TLSv1)


class TLS1Handler(urllib2.HTTPSHandler):
    def __init__(self):
        urllib2.HTTPSHandler.__init__(self)

    def https_open(self, req):
        return self.do_open(TLS1Connection, req)

def main():
#	csv_file = raw_input('Path to CSV: ')    
    csv_file = "/Users/Shared/itunesurl.csv"

    logging.basicConfig(filename="/Users/Shared/app_id_log.log",level=logging.DEBUG,format='%(asctime)s [%(levelname)s] %(message)s')

    logging.info("Starting Check")

    lookup_url = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsLookup?id="

    app_list = []

    # Extract the app ids from the iTunes URL
    with open(csv_file.replace('\\','').strip(),'rU') as app_id_file:
            appIDReader = csv.reader(app_id_file,delimiter=',')
            for tagRow in appIDReader:
            	try:
                    app_id = re.search('id(\d+)', tagRow[0]).groups()[0]
                    app_list.append(app_id)
                except IndexError as e:
                    logging.error("Bad Index")

    # Loop through all the app ids to find the bad ones
    for app_id in app_list:
        opener = urllib2.build_opener(TLS1Handler())
        request = urllib2.Request("%s%s" % (lookup_url,app_id))
        request.get_method = lambda: 'GET'
    
        try:
            response = opener.open(request)
            results = json.load(response)
            if results['resultCount'] == 0:
                print "App With ID: %s - Bad" % app_id
        except urllib2.HTTPError as e:
            logging.error("Bad URL Lookup: %s%s" % (lookup_url,app_id))
        except urllib2.URLError as e:
            logging.error("Bad URL Lookup: %s%s" % (lookup_url,app_id))

main()
