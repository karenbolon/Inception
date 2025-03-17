#!/bin/bash

WP_PATH="/var/www/html"

#fix ownership and permissions
chown -R www-data:www-data $WP_PATH

#ensure PHP-RPM socket directory exists
mkdir -p /run/php/
chown www-data:www-data /run/php
chmod 755 /run/php

if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "[### WP-CONFIG.PHP NOT FOUND, CREATING... ###]"
	if ! su - www-data -s /bin/sh -c "wp config create \
		--dbname='$MDB_DB_NAME' \
		--dbuser='$MDB_USER' \
		--dbpass='$(cat /run/secrets/mdb_pw)' \
#		--dbhost='mariadb:3306' \
		--dbhost='$DB_HOST' \
		--path=$WP_PATH"; then
		echo "[### ERROR CREATING WP_CONFIG.PHP ###]"
		exit 1
	fi
fi


echo "[### CHECKING MARIADB STATUS ###]"
until mysqladmin ping -h"$DB_HOST" --silent; do
	echo "[### WAITING FOR MARIADB ###]"
	sleep 5
done
echo "[### MARIADB IS UP AND RUNNING ###]"

#give mariadb time to set up
#sleep 10

#Wait for MariaDB server to be running
#end_time=$(( SECONDS + 30 ))
#while (( SECONDS < end_time )); do
#	if nc -zq 1 mariadb 3306; then
#		echo "[### MARIADB IS UP AND RUNNING ###]"
#		break
#	else
#		echo "[### WAITING FOR MARIADB TO START ###]"
#		sleep 5
#	fi
#done

#if (( SECONDS >= end_time )); then
#	echo "[### ERROR: MARIADB IS NOT RESPONDING! ###]"
#	exit 1
#fi

#Install wp-cli if missing
if ! command -v wp &>/dev/null; then
	echo "[### INSTALLING WP_CLI ###]"
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

#Download wordpress if missing
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
	echo "[### DOWNLOADING WORDPRESS ###]"
	wp --allow-root --path="$WP_PATH" core download || true
else
	echo "[### WORDPRESS ALREADY DOWNLOADED ###]"
fi

# Check if WordPress is installed, otherwise install
if ! wp --allow-root --path="$WP_PATH" core is-installed; then
    echo "[### INSTALLING WORDPRESS ###]"
    wp --allow-root --path="$WP_PATH" core install \
        --url="https://$DOMAIN_NAME/blog" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_NAME" \
        --admin_password="$(cat /run/secrets/wp_admin_pw)" \
        --admin_email="$WP_ADMIN_EMAIL"
else
	echo "[### WORDPRESS ALREADY INSTALLED ###]"
fi

#ensure wordpress user exists
if ! wp --allow-root --path="$WP_PATH" user get "$WP_USER_NAME"; then
    wp --allow-root --path="$WP_PATH" user create \
		"$WP_USER_NAME" "$WP_USER_EMAIL" \
        --user_pass="$(cat /run/secrets/wp_user_pw)" \
        --role="$WP_USER_ROLE"
	echo "[### WordPress user created ###]"
else
    echo "[### WordPress user already exists ###]"
fi

#install and activate theme
if ! wp --allow-root --path="$WP_PATH" theme is-installed raft; then
	echo "[### INSTALLING THEME: RAFT ###]"
	wp --allow-root --path="$WP_PATH" theme install raft --activate
else
	echo "[### THEME ALREADY INSTALLED ###]"
fi

#restart PHP-FPM
#service php7.4-fpm restart

# Start PHP-FPM service in the foreground to keep the container running


if pgrep -x "php-fpm7.4" > /dev/null; then
	echo "[### PHP-FPM IS ALREADY RUNNING ###]"
else
	echo "[### STARTING PHP-FPM ###]"
	exec php-fpm7.4 --nodaemonize
fi