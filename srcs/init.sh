#!/bin/bash

#define colours
GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

ENV_FILE="srcs/.env"

HOME_DIR="/home/ubuntu"
SECRETS_DIR="$HOME_DIR/Documents/Inception/secrets"

#Function to generate a random password
generate_password() {
	local flag="$1"
	if [ ! -f "$flag" ]; then
		openssl rand -base64 8 > "$flag"
		echo -e "${GREEN}$flag created${RESET}"
	else
		echo -e "${BLUE}$flag already exists${RESET}"
	fi
}

#create directories
make_directories() {
	local	path="$1"
	local	permissions="$2"

	if [ ! -d "$path" ]; then
		mkdir -p "$path"
		[ -n "$permissions" ] && chmod "0$permissions" "$path"
		chmod -R "$permissions" "$path"
		echo -e "${GREEN}$path: created${RESET}"
	else
		echo -e "${BLUE}$path already exists${RESET}"
		chmod -R "$permissions"  "$path"
	fi
}

make_directories "$SECRETS_DIR" 700
make_directories "$HOME_DIR/data/mariadb_data" 777
#sudo chown -R 999:999 "$HOME_DIR/data/mariadb_data"
make_directories "$HOME_DIR/data/wordpress_data" 775
#sudo chown -R 1000:1000 "$HOME_DIR/data/wordpress_data"

generate_password "$SECRETS_DIR/wp_user_pw.txt"
generate_password "$SECRETS_DIR/wp_admin_pw.txt"
generate_password "$SECRETS_DIR/mdb_pw.txt"
generate_password "$SECRETS_DIR/mdb_root_pw.txt"

REQUIRED_VARS=(
	"DOMAIN_NAME=kbolon.42.fr"
	"MDB_USER=kbolon"
	"MDB_DB_NAME=wordpress"
	"WP_TITLE=inception"
	"WP_ADMIN_NAME=kbolon"
	"WP_ADMIN_EMAIL=kbolon@gmail.com"
	"WP_USER_NAME=user"
	"WP_USER_EMAIL=user@gmail.com"
	"WP_USER_ROLE=author"
	"DB_HOST=mariadb"
)

#create .env if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
	#write a heredoc to save everything to .env
	echo -e "${BLUE}Creating .env file${RESET}"
	touch "$ENV_FILE"
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

#export the items in .env file to be used in making SSL keys etc
# '^#' this ignores lines beginning with #
#xargs lines into a format export can use
export $(grep -v '^#' $ENV_FILE | xargs)

#create ssl certificates if not created
if [ ! -f "$SECRETS_DIR/nginx.crt" ] || [ ! -f "$SECRETS_DIR/nginx.key" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout $SECRETS_DIR/nginx.key -out $SECRETS_DIR/nginx.crt \
		-subj "/CN=${DOMAIN_NAME}"
	openssl x509 -in $SECRETS_DIR/nginx.crt -addtrust serverAuth -out $SECRETS_DIR/nginx.crt
	echo -e "${GREEN}SSL certificates created${RESET}"
else
	echo -e "${BLUE}SSL certificates already created${RESET}"
fi
