#!/bin/bash

RED='\033[31m' #'\e[31m'
RESET='\033[0m' #'\e[0m'

LOG_FILE="/var/log/mariadb.log"
DB_DATA_DIR="/var/lib/mysql"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_USER_PASSWORD="$(cat /run/secrets/db_user_password)"
DB_NAME="inception"
DB_USER="kbolon"

#check if socket directory exists with correct permissions
#setup_socket() {
echo "Setting up MySQL socket directory"
mkdir -p /run/mysqld/
chown -R mysql:mysql /run/mysqld/
chmod 755 /run/mysqld/
#}

#set log file for mariadb
#setup_logging() {
echo "Setting up log files for mariadb"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
chown mysql:mysql "$LOG_FILE"
#}

#start mariadb in background
echo "Starting Mariadb"
mysqld_safe --datadir="$DB_DATA_DIR" > "$LOG_FILE" 2>&1 &

TIMEOUT=60
START_TIME=$(date +%s)
while ! mysqladmin ping -uroot -p"$DB_ROOT_PASSWORD" --silent; do
	if [ $(( $(date +%s) - START_TIME)) -gt $TIMEOUT ]; then
		echo -e "${RED}Error: Mariadb timed out${RESET}"
		exit 1
	fi
	sleep 2
done

echo "Mariadb started"

#initialise DB if it doesn't exist
#-e: execute
DB_EXISTS=$(mysql -uroot -p"$DB_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$DB_NAME'" | grep -q "$DB_NAME"; echo $?)
if [ "$DB_EXISTS" -eq 1 ]; then
	echo "Creating Database and User"
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" # || { echo 'Failed to initialize database.' >> /var/log/mariadb_env_vars.log; exit 1; }
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';" #||  { echo 'Failed to create user' >> /var/log/mariadb_env_vars.log; exit 1; }
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';" # || { echo 'Failed to grant privileges.' >> /var/log/mariadb_env_vars.log; exit 1; }
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" #||  { echo 'Failed to initialize database.' >> /var/log/mariadb_env_vars.log; exit 1; }
	echo "Database and user created successfully."
else
	echo "DB and user already created"
fi
