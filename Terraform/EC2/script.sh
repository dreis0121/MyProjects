#!/bin/bash

yum update -y
yum install httpd -y
echo "hello" > /var/www/html/index.html
service httpd start