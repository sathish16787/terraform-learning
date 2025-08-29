#!/bin/bash
yum update -y
amazon-linux-extras enable nginx1
yum install -y nginx

cat >  /usr/share/nginx/html/index.html  << EOF
<h1>Hello World</h1>
<p>DB Address ${db_address}</p>
<p> DB Port ${db_port} </p> 
EOF

systemctl start nginx
systemctl enable nginx

