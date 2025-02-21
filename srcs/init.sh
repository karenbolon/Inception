#!/bin/bash

#define colours
GREEN='\033[32m' #'\e[32m'
BLUE='\033[34m' #'\e[34m'
RED='\033[31m' #'\e[31m'
RESET='\033[0m' #'\e[0m'

SECRETS_DIR="/Users/karenbolon/Documents/Inception/secrets"
#SECRETS_DIR="/home/kbolon/Documents/Inception/secrets"

#Function to generate a random password
generate_password() {
	local flag="$1"
	if [ ! -f "$flag" ]; then
		openssl rand -base64 8 > "$flag"
		echo -e "${GREEN}$flag created${RESET}"
	else
		echo -e "${RED}$flag already exists${RESET}"
	fi	
}

#create directories
make_directories() {
	local path="$1"
	local permissions="$2"

	if [ ! -d "$path" ]; then
		mkdir -p "$path"
		[ -n "$permissions" ] && chmod "$permissions" "$path"
		echo -e "${GREEN}$path: created${RESET}"
	else
		echo -e "${RED}$path already exists${RESET}"
	fi
}


make_directories "$SECRETS_DIR" 700
#MACOS
make_directories "/Users/karenbolon/data/mariadb"
make_directories "/Users/karenbolon/data/wordpress"
#LINUX:
#make_directories "/home/kbolon/data/mariadb"
#make_directories "/home/kbolon/data/wordpress"

generate_password "$SECRETS_DIR/wp_user_password.txt"
generate_password "$SECRETS_DIR/wp_root_password.txt"
generate_password "$SECRETS_DIR/db_user_password.txt"
generate_password "$SECRETS_DIR/db_root_password.txt"


#create ssl certificates if not created
if [ ! -f "$SECRETS_DIR/nginx.crt" ] || [ ! -f "$SECRETS_DIR/nginx.key" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $SECRETS_DIR/nginx.key -out $SECRETS_DIR/nginx.crt -subj "/CN=kbolon.42.fr" 2> /dev/null
	echo -e "${GREEN}SSL certificates created${RESET}"
else
	echo -e "${RED}SSL certificates already created${RESET}"
fi

#create .ENV (removes previous .env if found)
if [ ! -f "srcs/.env" ]; then
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
WP_USER_ROLE=author
EOF
	echo -e "${GREEN}.env file has been created${RESET}"
else
	echo -e "${RED}.env already exists${RESET}"
fi