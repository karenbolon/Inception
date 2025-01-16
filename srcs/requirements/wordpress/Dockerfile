FROM debian:bullseye

RUN mkdir -p /var/www/wordpress

#install nginx and openssl for TLS
RUN apt update && apt upgrade -y && \
	apt install -y php-fpm php-mysql curl && \
	rm -rf /var/lib/apt/lists/*

COPY ./tools/wp_script.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wp_script.sh
#COPY ./tools/wp-config.php /

#for TLS use port 443 and 80
#EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_script.sh"]