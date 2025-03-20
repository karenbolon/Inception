#!/bin/bash

chown -R mysql:mysql /var/lib/mysql

#check if MariaDb has already been initialised
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initialising MariaDB data directory" 
#	>> /var/log/mysql/error.log
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
#	chmod 755 /var/lib/mysql
fi

#need to ensure the mariadb has started so we can execute SQL (build DB)
#service mariadb start

#start the mariadb service
mysqld_safe --datadir='/var/lib/mysql' &

#wait for MariaDB to fully start so we can execute SQL commands
sleep 5
#until mysqladmin ping -uroot -p"$(cat /run/secrets/mdb_root_pw)" --silent; do
#	echo "Waiting for MariaDB to start"
#	sleep 5
#done

#check if database already exists
#DB_EXISTS=$(mysql -uroot -p"$(cat /run/secrets/mdb_root_pw)" -Nse "SHOW DATABASES LIKE '$MDB_DB_NAME'" | grep "$MDB_DB_NAME" > /dev/null; echo "$?")

#create datase if it does not exist
#if [ "$DB_EXISTS" -ne 0 ]; then
#	echo "Database does not exist. Creating database and user" >> /var/log/mariadb.log
#	mysql -uroot -p"$(cat /run/secrets/mdb_root_pw)" -e "CREATE DATABASE IF NOT EXISTS \`$MDB_DB_NAME\`" \
#		|| { echo 'Failed to create database' >> /var/log/mariadb.log; exit 1; }
#	mysql -uroot -p"$(cat /run/secrets/mdb_root_pw)" -e "CREATE USER IF NOT EXISTS '$MDB_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/mdb_pw)'" \
#		|| { echo 'Failed to create user' >> /var/log/mariadb.log; exit 1; }
#	mysql -uroot -p"$(cat /run/secrets/mdb_root_pw)" -e "GRANT ALL PRIVILEGES ON \`$MDB_DB_NAME\`.* TO '$MDB_USER'@'%'" \
#		|| { echo 'Failed to grant privileges' >> /var/log/mariadb.log; exit 1; }
#	mysql -uroot -p"$(cat /run/secrets/mdb_root_pw)" -e "FLUSH PRIVILEGES;" \
#		|| { echo 'Failed to flush privileges' >> /var/log/mariadb.log; exit 1; }
#	echo "Database and user created successfully." >> /var/log/mariadb.log
#	sleep 5
#else
#	echo "Database already exists." >> /var/log/mariadb.log
#fi

mariadb -v -u root << EOF
    CREATE DATABASE IF NOT EXISTS \`$MDB_DB_NAME\`;
    CREATE USER IF NOT EXISTS '$MDB_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/mdb_pw)';
    GRANT ALL PRIVILEGES ON \`$MDB_DB_NAME\`.* TO '$MDB_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/mdb_pw)';
    GRANT ALL PRIVILEGES ON \`$MDB_DB_NAME\`.* TO 'root'@'%' IDENTIFIED BY '$(cat /run/secrets/mdb_root_pw)';
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat /run/secrets/mdb_root_pw)');
EOF

sleep 5

#stop the MariaDB service started by the service command
mysqladmin shutdown -uroot -p"$(cat /run/secrets/mdb_root_pw)"
#service mariadb stop

#Start MariaDB up again in the foreground and keep the container running
exec mysqld_safe --datadir='/var/lib/mysql'
#service mariadb start
