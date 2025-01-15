FROM debian:bullseye

#install nginx and openssl for TLS
RUN apt update && apt upgrade -y
RUN	apt install -y nginx openssl
RUN rm -rf /var/lib/apt/lists/*

#copy nginx configuration
COPY conf/nginx.conf /etc/nginx/sites-available/default
#COPY tools/index.html /usr/share/nginx/html

RUN openssl req -x509 -days 365 -nodes -newkey rsa:2048 \
	-keyout /etc/ssl/certs/nginx.key \
	-out /etc/ssl/certs/nginx.crt -sha256 -subj "/CN=kbolon.42.fr"

#RUN mkdir -p /etc/nginx/ssl
#RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/nginx_inception.crt -keyout /etc/nginx/ssl/nginx_inception.key -subj "/CN=kbolon.42.fr"
#RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/inception.crt       -keyout /etc/nginx/ssl/inception.key       -subj "/CN=localhost/UID=login"

#for TLS (HTTPS) use port 443 and 80
#EXPOSE 443

#start NGINX in the foreground, daemon off so container 
#doesn't exit abruptly when powered on
CMD  ["nginx", "-g", "daemon off;"]

