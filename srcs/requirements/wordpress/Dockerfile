FROM debian:bullseye

#create WordPress directory
RUN	mkdir -p /var/www/html

RUN	apt update && apt install -y php-fpm php-mysql curl iproute2 netcat && \
	rm -rf /var/lib/apt/lists/*

#Force PHP-FPM to listen on all network interfaces (not just localhost)
RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf

#copy wordpress initialisation script
COPY	srcs/requirements/wordpress/tools/wp-config.sh	/usr/local/bin/wp-config.sh
RUN	chmod +x /usr/local/bin/wp-config.sh

COPY	srcs/requirements/wordpress/conf/wp-config.php /var/www/html/wp-config.php
RUN	chmod 644 /var/www/html/wp-config.php && \
	chown www-data /var/www/html/wp-config.php

#expose PHP-FPM port
EXPOSE 9000

#start wordpress using init script
ENTRYPOINT ["/usr/local/bin/wp-config.sh"]
