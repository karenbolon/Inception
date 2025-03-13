#!/bin/bash

#define colours
GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

ENV_FILE="srcs/.env"

SECRETS_DIR="$HOME_PATH/Documents/Inception/secrets"

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
	local	path="$1"
	local	permissions="$2"

	if [ ! -d "$path" ]; then
		mkdir -p "$path"
		[ -n "$permissions" ] && chmod "0$permissions" "$path"
		chown -R kbolon:kbolon "$path"
		echo -e "${GREEN}$path: created${RESET}"
	else
		echo -e "${RED}$path already exists${RESET}"
		chown -R kbolon:kbolon "$path"
	fi
}

make_directories "$SECRETS_DIR" 700
make_directories "$HOME_PATH/data/mariadb"
make_directories "$HOME_PATH/data/wordpress"

generate_password "$SECRETS_DIR/wp_user_pw.txt"
generate_password "$SECRETS_DIR/wp_admin_pw.txt"
generate_password "$SECRETS_DIR/mdb_pw.txt"
generate_password "$SECRETS_DIR/mdb_root_pw.txt"

#create ssl certificates if not created
if [ ! -f "$SECRETS_DIR/nginx.crt" ] || [ ! -f "$SECRETS_DIR/nginx.key" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout $SECRETS_DIR/nginx.key -out $SECRETS_DIR/nginx.crt \
		-subj "/CN=${DOMAIN}"
	openssl x509 -in $SECRETS_DIR/nginx.crt -addtrust serverAuth -out $SECRETS_DIR/nginx.crt
	echo -e "${GREEN}SSL certificates created${RESET}"
else
	echo -e "${RED}SSL certificates already created${RESET}"
fi

REQUIRED_VARS=(
	"USER_NAME=kbolon"
	"DOMAIN_NAME=kbolon.42.fr"
	"MDB_USER=kbolon"
	"MDB_DB_NAME=database"
	"WP_TITLE=inception"
	"WP_ADMIN_NAME=kbolon"
	"WP_ADMIN_EMAIL=kbolon@gmail.com"
	"WP_USER_NAME=user"
	"WP_USER_EMAIL=user@gmail.com"
	"WP_USER_ROLE=author"
	"HOME_PATH=/Users/karenbolon"
)

#create .env if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
	#write a heredoc to save everything to .env
	echo -e "${BLUE}Creating .env file${RESET}"
	tough "$ENV_FILE"
fi

#check if each required variable exists and adds if missing
for VAR in "${REQUIRED_VARS[@]}"; do
	KEY=$(echo "$VAR" | cut -d= -f1)

	if grep -q "^$KEY=" "$ENV_FILE"; then
		echo -e "${GREEN}$KEY exists in .env${RESET}"
	else
		echo -e "${RED}$KEY is missing! Added to .env${RESET}"
		echo "$VAR" >> "$ENV_FILE"
	fi
done

echo -e "${GREEN}Environment file has been checked/created!${RESET}"

