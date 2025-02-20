#!/bin/bash

#Function to generate a random password
generate_password() {
	openssl rand -base64 8
}

#create directories
if [ ! -d "secrets" ]; then
	mkdir -p "/home/kbolon/Documents/Inception/secrets"
	chmod -m 775 secrets
	echo "secrets folder created"
echo
	"secrets folder already exists"
fi

if [ ! -d "/home/kbolon/data/mariadb" ]; then
	mkdir -p "/home/kbolon/data/mariadb"
	echo "mariadb folder created"
echo
	"mariadb folder already exists"
fi

if [ ! -d "/home/kbolon/data/wordpress" ]; then
	mkdir -p "/home/kbolon/data/wordpress"
	echo "wordpress folder created"
echo
	"wordpress folder already exists"
fi

#create passwords for WordPress and MariaDB
if [ ! -f "secrets/wp_user_password.txt" ]; then
	generate_password > secrets/wp_user_password.txt
	echo "wp_user_password created"
else
	echo "wp_user_password already exists"
fi

if [ ! -f "secrets/wp_root_password.txt" ]; then
	generate_password > secrets/wp_root_password.txt
	echo "wp_root_password created"
else
	echo "wp_root_password already exists"
fi

if [ ! -f "secrets/db_user_password.txt" ]; then
	generate_password > secrets/db_user_password.txt
	echo "db_user_password created"
else
	echo "db_user_password already exists"
fi

if [ ! -f "secrets/db_root_password.txt" ]; then
	generate_password > secrets/db_root_password.txt
	echo "db_root_password created"
else
	echo "db_root_password already exists"
fi


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