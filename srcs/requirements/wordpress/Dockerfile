FROM debian:bullseye

#install nginx and openssl for TLS
RUN apt update && apt upgrade -y && \
	apt install -y php-fpm php-mysql curl && \
	rm -rf /var/lib/apt/lists/*

COPY ./tools/wp_script.sh /
COPY ./tools/wp_config.php /
#COPY www.conf /etc/php/8.2/fpm/pool.d
#COPY index.php ./web:/var/www/php
#RUN chmod +x /var/www/wordpress/wp_script.sh

#for TLS use port 443 and 80
#EXPOSE 9000

#start WordPress in the foreground and ignore the 
#Daemon option from config file
CMD ["/wp_script.sh"]