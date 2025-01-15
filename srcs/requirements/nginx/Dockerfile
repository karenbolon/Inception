FROM debian:bullseye

#install nginx and openssl for TLS
RUN apt update && apt upgrade -y && \
	apt install -y nginx openssl \
	&& rm -rf /var/lib/apt/lists/*

#copy nginx configuration from host machine to docker container
COPY conf/nginx.conf /etc/nginx/nginx.conf

#TSL
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/CN=kbolon.42.fr"

#for for HTTP & HTTPS to allow external connections (TLS)
EXPOSE 443

#ENV DOMAIN_NAME=$DOMAIN_NAME

#start NGINX in the foreground, daemon off so container 
#doesn't exit abruptly when powered on
CMD  ["nginx", "-g", "daemon off;"]
