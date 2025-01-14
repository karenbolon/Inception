#!/bin/bash

#creating MYSQL init script
echo "CREATE DATABASE IF NOT EXISTS \'${MYSQL_DATABASE_NAME}\';" > /etc/mysql/init.sql

#@'%': Allows the user to connect from any host (% is a wildcard for any IP).
echo "CREATE USER IF NOT EXISTS \'${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat $DB_PASSWORD)';" >> /etc/mysql/init.sql

echo "GRANT ALL PRIVILEGES ON \'${MYSQL_DATABASE_NAME}\'.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat $DB_PASSWORD)';" >> /etc/mysql/init.sql

#change root password for localhost
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY  '$(cat $DB_ROOT_PWD)';" >> /etc/mysql/init.sql

#reload the tables to apply any changes
echo "FLUSH PRIVILEGES;" >> /etc/mysql/init.sql

#Start MariaDB with the init.sql
exec mysqld_safe --bind_address=0.0.0.0
