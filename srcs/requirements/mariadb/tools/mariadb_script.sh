#!/bin/bash

RED='\033[31m'
RESET='\033[0m'

# Read database password from Docker secrets
DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)

# Ensure MariaDB directories exist with correct permissions
mkdir -p /run/mysqld /var/lib/mysql /var/log/mariadb
chown -R mysql:mysql /run/mysqld/ /var/lib/mysql /var/log/mariadb
chmod 755 /run/mysqld /var/lib/mysql /var/log/mariadb

# Initialize database if missing
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Start MariaDB in foreground
echo "Starting MariaDB..."
exec mariadbd --datadir=/var/lib/mysql &

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
TIMEOUT=60
START_TIME=$(date +%s)

while ! mysqladmin ping -h 127.0.0.1 --silent; do
    sleep 2
    if [ $(( $(date +%s) - START_TIME )) -gt $TIMEOUT ]; then
        echo -e "${RED}ERROR: MariaDB failed to start${RESET}"
        exit 1
    fi
done
echo "MariaDB is ready!"

# Check if the database exists inside MariaDB
if ! mariadb -uroot -e "USE $DB_NAME;" 2>/dev/null; then
    echo "Creating Database and User..."
    
    mariadb -uroot <<EOF
    CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
    CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';
    GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
    FLUSH PRIVILEGES;
EOF

    echo "Database and user created successfully."
else
    echo "Database and user already exist."
fi

# Keep MariaDB running in foreground
exec mariadbd --datadir=/var/lib/mysql
