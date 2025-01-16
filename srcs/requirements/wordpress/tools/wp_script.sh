#!/bin/bash

#checks if wp-cli is available
if ! command -v wp &>/dev/null; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

#sets working directly
cd /var/www/html || { echo "ERROR: /var/www/html not found"; exit 1; }

#validate environment variables
VARIABLES=("DB_HOST" "DB_NAME" "DB_USER" "DB_PASSWORD" "WP_TITLE" "DOMAIN_NAME" \
	"WP_ADMIN" "WP_ADMIN_EMAIL" "WP_ADMIN_PASSWORD" "WP_USER" "WP_USER_EMAIL" \
	"WP_USER_PASSWORD" )
for VAR in "${VARIABLES[@]}";do
	if [ -z "${!VAR}" ]; then
		echo "ERROR: missing environment variable $VAR"
		exit 1
	fi
done

#install WordPress
if [ ! -d "wp-admin" ]; then
	echo "Downloading WordPress"
	wp core download --allow-root || { echo "ERROR: WP download failed"; exit 1; }
else
	echo "WP is installed"
fi

#wait for mariadb connection (with a timeout)
TIMEOUT=60
START_TIME=$(date +%s)
while ! mysqladmin ping --host=$DB_HOST --silent; do
	sleep 5
	ELAPSED=$(( $(date +%s) - START_TIME ))
	if [ $ELAPSED -ge $TIMEOUT ]; then
		echo "ERROR: DB connection timed out"
		exit 1
	fi
done

#configure WP 
if [ ! -e "wp-config.php" ]; then
	wp config create \
		--dbname=$DB_NAME \
		--dbuser=$DB_USER \
		--dbpass=$DB_PASSWORD \
		--dbhost=$DB_HOST \
		--allow-root || { echo "ERROR: failed to make wp-config.php"; exit 1; }

	#install wordpress
	wp core install \
		--title=$WP_TITLE \
		--url=$DOMAIN_NAME \
		--admin_user=$WP_ADMIN \
		--admin_email=$WP_ADMIN_EMAIL \
		--admin_password=$WP_ADMIN_PASSWORD \
		--allow-root || { echo "ERROR: WordPress failed to install"; exit 1; }

	#create additional user
	wp user create $WP_USER_NAME $WP_USER_EMAIL \
		--user_pass=$WP_USER_PASSWORD \
		--role=editor \
		--allow-root || { echo "ERROR: Problems creating WP user"; exit 1; }
else
	echo "WP is configured"
fi

#check if PHP socket directory exists
if [ ! -d /run/php ]; then
	mkdir -p /run/php
	chown www-data:www-data /run/php
fi

#start php-fpm dynamically
PHP_FPM=$(which php-fpm)
if [ -z "$PHP_FPM" ]; then
	echo "ERROR: php-fpm not found"
	exit 1
fi

exec $PHP_FPM -F