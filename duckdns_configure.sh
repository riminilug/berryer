#!/bin/bash
#
# Description: Auto system to to setup a privacy wall on Raspbian
#
# Copyright (C) 2019 Simone Foschi <s.foschi@gmail.com>
#

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Script must be run under sudo."
    exit 1
fi

echo "Before starting the procedure, ensure you have a duckdns.org domain."
echo "The procedure requires the token of your duckdns account to configure correctly the domain."
read -p "Insert the domain name eg.: mydomain.duckdns.org and press [enter]" DOMAIN
read -p "Insert the token of your account and press [enter]" TOKEN
echo "This procedure will install and configure all software for a working duckdns.org DDNS domain on a Raspbian"
echo "Starting procedure.."
apt install curl

mkdir duckdns
cd duckdns

echo "echo url=\"https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=\" | curl -k -o $(pwd)/duck.log -K -" > duck.sh

chmod 700 duck.sh

(crontab -l 2>/dev/null; echo "*/5 * * * * $(pwd)/duck.sh >/dev/null 2>&1") | crontab -
echo "Procedure finished"
echo "You can view updated crontab typing"
echo "sudo crontab -e"