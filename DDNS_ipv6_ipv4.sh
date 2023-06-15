#!/bin/bash

# This script is used to check and update your GoDaddy DNS server to the IP address of your current internet connection.
# Special thanks to mfox for his ps script
# https://github.com/markafox/GoDaddy_Powershell_DDNS
#
# First go to GoDaddy developer site to create a developer account and get your key and secret
#
# Be aware that it uses jq to parse the outcome of current records.
#
# https://developer.godaddy.com/getstarted
# Be aware that there are 2 types of key and secret - one for the test server and one for the production server
# Get a key and secret for the production server
#
# Added support to update ipv6 and ipv4 adresses in the AAAA and A records.
# Please uncomment the echo-lines if you want some logging.
#
#Update the first 5 variables with your information

log="/var/log/ipupdate"
domain="somedomain.com"   # your domain
name="somesubdomain"     # name of A and AAAA record to update enter @ for root domain
key="apikey"     # key for godaddy developer API
secret="secret"   # secret for godaddy developer API

headers="Authorization: sso-key $key:$secret"

# echo $headers

result=$(curl -s -X GET -H "$headers" \
 "https://api.godaddy.com/v1/domains/$domain/records/A/$name")
result6=$(curl -s -X GET -H "$headers" \
 "https://api.godaddy.com/v1/domains/$domain/records/AAAA/$name")

dnsIp=$(echo $result | jq -r .[].data)
dnsIp6=$(echo $result6 | jq -r .[].data)

# Get public ip address there are several websites that can do this.
currentIp=$(curl -s ipv4.icanhazip.com)
currentIp6=$(curl -s ipv6.icanhazip.com)

if [ "$dnsIp" != "$currentIp" ];
 then
#	 echo "$(date --rfc-3339=seconds) - Ip4 are not equal" >> $log
	request='[{"data":"'$currentIp'","ttl":3600}]'
#	 echo "$(date --rfc-3339=seconds) - request:" $request >> $log
	nresult=$(curl -i -s -X PUT \
 -H "$headers" \
 -H "Content-Type: application/json" \
 -d $request "https://api.godaddy.com/v1/domains/$domain/records/A/$name")
#	  echo "$(date --rfc-3339=seconds) - result:" $nresult >> $log
fi

if [ "$dnsIp6" != "$currentIp6" ];
 then
#	 echo "$(date --rfc-3339=seconds) - Ip6 are not equal" >> $log
	request='[{"data":"'$currentIp6'","ttl":3600}]'
#	 echo "$(date --rfc-3339=seconds) - request:" $request >> $log
	nresult=$(curl -i -s -X PUT \
 -H "$headers" \
 -H "Content-Type: application/json" \
 -d $request "https://api.godaddy.com/v1/domains/$domain/records/AAAA/$name")
#	  echo "$(date --rfc-3339=seconds) - result:" $nresult >> $log
fi
