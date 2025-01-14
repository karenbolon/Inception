FROM debian:bullseye

#insall nginx and openssl for TLS
RUN apt update && apt upgrade -y && \
	apt install -y php-fpm php-mysqli curl && \
	apt clean

#copy static website files and nginx configuration
#COPY tools/index.html /usr/share/nginx/html
#COPY conf/default.conf /etc/nginx/conf.d/

COPY www.conf /etc/php/8.2/fpm/pool.d/.
COPY index.html ./web:/var/www/html
#COPY index.php ./web:/var/www/php
COPY wp_script.sh .
RUN chmod +x wp_script.sh

#for TLS use port 443 and 80
#EXPOSE 80 443

#ENV DOMAIN_NAME=$DOMAIN_NAME

#start WordPress in the foreground and ignore the 
#Daemon option from config file
CMD ["./wp_script.sh"]