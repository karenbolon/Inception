#!/bin/bash

#check if socket directory exists with correct permissions
setup_socket() {
	mkdir -p /run/mysqld/
	chown mysql:mysql /run/mysqld/
	chmod 755 /run/mysqld/
}

#wait for DB to start
wait_for_mdb() {
	mysqld_safe --datadir='var/lib/mysql' &
	until mysqladmin ping -uroot -p "$(cat "$DB_ROOT_PW")" --silent; do
		sleep 1
	done
}

#initialise DB if it doesn't exist
#-e: execute
init_database {
	if ! mysql -uroot -p"$(cat "DB_ROOT_PW")" -e "SHOW DATABASES LIKE '$DB_NAME'" | grep -q "$DB_NAME"; then
		mysql -uroot -p$(cat "$DB_ROOT_PW")" <<-EOSQL ||  { echo 'Failed to initialize database.' >> /var/log/mariadb_env_vars.log; exit 1; }
 			CREATE DATABASE IF NOT EXISTS \'$DB_NAME\';
			CREATE USER IF NOT EXISTS \'$(DB_USER)'@'%' IDENTIFIED BY '$(cat $DB_PASSWORD)';" >> /etc/mysql/init.sql
			GRANT ALL PRIVILEGES ON \'$(DB_NAME)\'.* TO '${DB_USER}'@'%';
			FLUSH PRIVILEGES;
		EOSQL
		echo "DB and user created" >> /var/lost/mariadb_env_vars.log
	else
		echo "DB already exists" >> /var/lost/mariadb_env_vars.log
	fi
}

main() {
	setup_socket
	wait_for_mdb
	init_database
	mysqladmin shutdown -uroot -p"$(cat "$DB_ROOT_PW")"
	exec mysqld_safe --datadir='/var/lib/mysql'
}