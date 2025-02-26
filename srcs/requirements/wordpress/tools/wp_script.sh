#!/bin/bash

RED='\033[31m' #'\e[31m'
RESET='\033[0m' #'\e[0m'

# Ensure wp-cli is installed, this executes admin tasks via the terminal
if ! command -v wp &>/dev/null; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar || { echo "ERROR: wp-cli download failed"; exit 1; }
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

# Set working directory
cd /var/www/html || { echo "ERROR: /var/www/html not found"; exit 1; }

# Fix ownership issues (important)
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Read secrets from files
#DB_PASSWORD=$(cat /run/secrets/db_user_password)
#WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
#WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Validate required environment variables
VARIABLES=("DB_HOST" "DB_NAME" "DB_USER" "DB_PASSWORD" "DOMAIN_NAME" \
	"WP_ADMIN_NAME" "WP_ADMIN_EMAIL" "WP_ADMIN_PASSWORD" "WP_USER_NAME" "WP_USER_EMAIL" \
	"WP_USER_PASSWORD")

for VAR in "${VARIABLES[@]}"; do
	if [ -z "${!VAR}" ]; then
		echo "ERROR: missing environment variable $VAR"
		exit 1
	fi
done


# Wait for MariaDB to be ready
TIMEOUT=60
START_TIME=$(date +%s)

while ! mysqladmin ping -h "$DB_HOST" ; do
	sleep 5
	if [ $(( $(date +%s) - START_TIME )) -ge $TIMEOUT ]; then
		echo -e "${RED}ERROR: MariaDB connection timed out${RESET}"
		exit 1
	fi
done

# Ensure wp-config.php is present
if [ ! -e "wp-config.php" ]; then
	echo "🔧 Creating wp-config.php..."
	wp config create \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST" \
		--allow-root || { echo "ERROR: Failed to create wp-config.php"; exit 1; }
fi

# Check if WordPress is installed, otherwise install
if ! wp core is-installed --allow-root; then
	echo "⚡ Installing WordPress..."
	wp core install \
		--url="https://$DOMAIN_NAME/blog" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_NAME" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--allow-root || { echo "ERROR: WordPress installation failed"; exit 1; }
else
	echo "WordPress already installed"
fi
