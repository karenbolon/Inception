FROM debian:bullseye

#create WordPress and PHP directories
RUN	mkdir -p /var/www/html && \
	mkdir -p /run/php/ && \
	mkdir -p /var/run/php/

RUN	apt update && apt install -y php-fpm php-mysql mariadb-client curl iproute2 netcat && \
	rm -rf /var/lib/apt/lists/*

#stop PHP-FPM before modifying config
RUN	service php7.4-fpm stop

#Modify PHP, force PHP-FPM to listen on all network interfaces (not just localhost)
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.4/fpm/php.ini && \
	sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's/;listen.mode = 0660/listen.mode = 0660/g'	/etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/7.4/fpm/pool.d/www.conf

#copy wordpress initialisation script
COPY	srcs/requirements/wordpress/tools/init.sh	/usr/local/bin/init.sh
RUN	chmod +x /usr/local/bin/init.sh

COPY	srcs/requirements/wordpress/conf/www.conf /etc/php/7.4/fpm/pool.d/
RUN	chmod 644 /etc/php/7.4/fpm/pool.d/www.conf && \
	chown www-data /etc/php/7.4/fpm/pool.d/www.conf

#expose PHP-FPM port
EXPOSE 9000

#start wordpress using init script
CMD ["/usr/local/bin/init.sh"]
