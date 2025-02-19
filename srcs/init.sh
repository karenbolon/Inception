#!/bin/bash

#Function to generate a random password
generate_password() {
	openssl rand -base64 8
}

#create passwords for WordPress and MariaDB
generate_password > secrets/wp_user_password.txt
generate_password > secrets/wp_root_password.txt
generate_password > secrets/db_user_password.txt
generate_password > secrets/db_root_password.txt
echo "Secrets and passwords created"

#create ssl certificates if not created
if [ ! -f "secrets/nginx.crt" ] || [ ! -f "secrets/nginx.key" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout secrets/nginx.key -out secrets/nginx.crt -subj "/CN=kbolon.42.fr" 2> /dev/null
	echo "SSL certificates created"
else
	echo "SSL certificates already created"
fi

#create .ENV (removes previous .env if found)
[ -f "srcs/.env" ] && rm -f srcs/.env

#write a heredoc to save everything to .env
cat <<EOF > srcs/.env
DOMAIN_NAME=kbolon.42.fr

#mariadb
DB_USER=kbolon
DB_NAME=database

#wordpress
WP_TITLE=inception
WP_ADMIN_NAME=kbolon
WP_ADMIN_EMAIL=kbolon@student.42berlin.de
WP_USER_NAME=user
WP_USER_EMAIL=user@gmail.com
WP_USER_ROLE=auther
EOF

echo ".env file has been created"