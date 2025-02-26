#!/bin/bash

# Define colors for error messages
RED='\033[31m'
RESET='\033[0m'

# Ensure working directory
mkdir -p /var/www/html
cd /var/www/html || { echo -e "${RED}ERROR: /var/www/html not found${RESET}"; exit 1; }

# Fix ownership issues
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
TIMEOUT=60
START_TIME=$(date +%s)

while ! mysqladmin ping -h "$DB_HOST" --silent; do
    sleep 5
    if [ $(( $(date +%s) - START_TIME )) -ge $TIMEOUT ]; then
        echo -e "${RED}ERROR: MariaDB connection timed out${RESET}"
        exit 1
    fi
done
echo "MariaDB is ready!"

# Ensure WordPress is installed
if [ ! -f "wp-load.php" ]; then
    echo "Downloading WordPress core files..."
    wp core download --allow-root
fi

# Ensure wp-config.php is present
#if [ ! -e "wp-config.php" ]; then
#    echo "Creating wp-config.php..."
#    wp config create \
#        --dbname="${DB_NAME}" \
#        --dbuser="${DB_USER}" \
#        --dbpass="${DB_PASSWORD}" \
#        --dbhost="${DB_HOST}" \
#        --allow-root || { echo -e "${RED}ERROR: Failed to create wp-config.php${RESET}"; exit 1; }
#fi

# Install WordPress if not already installed
if ! wp core is-installed --allow-root; then
    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}/blog" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_NAME}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root || { echo -e "${RED}ERROR: WordPress installation failed${RESET}"; exit 1; }
else
    echo "WordPress is already installed."
fi

# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
exec php-fpm -F
