#!/bin/bash

LOG_FILE="/var/log/mariadb.log"
DB_DATA_DIR="/var/lib/mysql"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_USER_PASSWORD="$(cat /run/secrets/db_user_password)"

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
#start_mariadb() {
echo "Starting Mariadb"
mysqld_safe --datadir="$DB_DATA_DIR" > "$LOG_FILE" 2>&1 &

#check if it actually started
#	ps aux | grep -q "[m]ysqld" || { echo "mariadb failed to start"; cat "$LOG_FILE"; exit 1;}

#}

#wait for DB to start
#wait_for_mdb() {
#	echo "Waiting for Mariadb to start"
#	TIMEOUT=60
#	START_TIME=$(date +%s)
until mysqladmin ping -uroot -p"$DB_ROOT_PASSWORD" --silent; do
	echo "Waiting for Mariadb to start"
	sleep 2
done
#		ELAPSED=$(( $(date +%s) - START_TIME ))
#		if [ $ELAPSED -ge $TIMEOUT ]; then
#			echo "ERROR: MariaDB startup timeout!"
#			exit 1
#		fi
#	done
#	echo "MariaDB is running"
#}



#initialise DB if it doesn't exist
#-e: execute
#init_database() {
echo "Checking if database exists"
DB_EXISTS=$(mysql -uroot -p"$DB_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$DB_NAME'" | grep -q "$DB_NAME"; echo $?)
if [ "$DB_EXISTS" -eq 1 ]; then
	echo "Database does not exist" >> /var/log/mariadb_env_vars.log
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" || { echo 'Failed to initialize database.' >> /var/log/mariadb_env_vars.log; exit 1; }
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';" ||  { echo 'Failed to create user' >> /var/log/mariadb_env_vars.log; exit 1; }
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';" || { echo 'Failed to grant privileges.' >> /var/log/mariadb_env_vars.log; exit 1; }
	mysql -uroot -p"$DB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" ||  { echo 'Failed to initialize database.' >> /var/log/mariadb_env_vars.log; exit 1; }
	echo "Database and user created successfully." >> /var/log/mariadb_env_vars.log;
else
	echo "DB and user already created"
fi
#}

main() {
	setup_socket
	setup_logging
	start_mariadb
	wait_for_mdb
	init_database
	echo "Mariadb setup is complete"
}

main