#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
echo "Hello from instance2" > /var/www/html/index.html