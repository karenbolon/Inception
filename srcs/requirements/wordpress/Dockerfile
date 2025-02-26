FROM debian:bullseye

# Create WordPress directory
RUN mkdir -p /var/www/html

# Install required packages
RUN apt update && apt upgrade -y && \
    apt install -y php-fpm php-mysql curl mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Download and extract WordPress core files
RUN wp core download --path=/var/www/html --allow-root

# Copy WordPress setup script
COPY ./tools/wp_script2.sh /usr/local/bin/wp_script2.sh
RUN chmod +x /usr/local/bin/wp_script2.sh

# Copy wp-config.php file into the correct directory
COPY ./conf/wp-config.php /var/www/html/wp-config.php
RUN chmod 644 /var/www/html/wp-config.php && chown www-data:www-data /var/www/html/wp-config.php

# Expose PHP-FPM port
EXPOSE 9000

# Start WordPress initialization
ENTRYPOINT ["/usr/local/bin/wp_script2.sh"]
