#!/bin/bash

country="US"
state="Wisconsin"
city="Eau Claire"
organization="Jamf"
department="Support"
read -p "Certificate common name or server FQDN: " address


# -=-=-=-=-=- #

# create the certificate signing request
openssl req -new -newkey rsa:2048 -nodes -out $address.csr -keyout $address.key -subj "/C=$country/ST=$state/L=$city/O=$organization/OU=$department/CN=$address"

# verify the contents of the CSR
openssl req -text -noout -verify -in $address.csr

# sign the CSR
openssl ca -in $address.csr -out $address.crt

# verify the contents of the signed certificate
openssl x509 -noout -text -in $address.crt

read -p "Delete the CSR? y/n " cleanup
if [[ "$cleanup" == "y" ]] ; then
        rm $address.csr
fi

echo "Your new certificate files are located at `pwd`/$address.key and `pwd`/$address.crt"
