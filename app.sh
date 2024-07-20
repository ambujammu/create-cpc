#!/bin/bash
apt update -y
apt install nginx -y
rm -r /var/www/html*
git clone https://github.com/ambujammu/create-cpc.git /var/www/html/