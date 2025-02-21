#!/bin/bash

#check if socket directory exists with correct permissions
setup_socket() {
	mkdir -p /run/mysqld/
	chown -R mysql:mysql /run/mysqld/
	chmod 755 /run/mysqld/
}

#wait for DB to start
wait_for_mdb() {
	mysqld_safe --datadir='/var/lib/mysql'
	sleep 5 #give time for mysqld to start
	#check if mariadb starts
	cat /var/log/mariadb_start.log
	TIMEOUT=60
	START_TIME=$(date +%s)
	until mysqladmin ping -uroot -p "$(cat /run/secrets/db_root_password)" --silent; do
		sleep 2
		ELAPSED=$(( $(date +%s) - START_TIME ))
		if [ $ELAPSED -ge $TIMEOUT ]; then
			echo "ERROR: MariaDB startup timeout!"
			exit 1
		fi
	done
}

#initialise DB if it doesn't exist
#-e: execute
init_database() {
	if ! mysql -uroot -p"$(cat /run/secrets/db_root_password)" -e "SHOW DATABASES LIKE '${DB_NAME}'" | grep -q "${DB_NAME}"; then
		mysql -uroot -p"$(cat /run/secrets/db_root_password)" <<-EOSQL ||  { echo 'Failed to initialize database.' >> /var/log/mariadb_env_vars.log; exit 1; }
 			CREATE DATABASE IF NOT EXISTS $DB_NAME;
			CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY "$(cat /run/secrets/db_user_password)";
			GRANT ALL PRIVILEGES ON $DB_NAME.* TO '${DB_USER}'@'%';
			FLUSH PRIVILEGES;
		EOSQL
		echo "DB and user created" >> /var/log/mariadb_env_vars.log
	else
		echo "DB already exists" >> /var/log/mariadb_env_vars.log
	fi
}

main() {
	setup_socket
	wait_for_mdb
	init_database
	echo "MariaDB is now running..."
#	mysqladmin shutdown -uroot -p"$(cat /run/secrets/db_root_password)"
	exec mysqld_safe --datadir='/var/lib/mysql'
}

main