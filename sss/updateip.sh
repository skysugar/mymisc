#!/bin/bash
# This script for chinadns

# update chnroute
curl -s 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > chnroute.txt

# update iplist
curl -s 'https://raw.githubusercontent.com/YKilin/ChinaDNS/master/iplist.txt' > iplist.txt
