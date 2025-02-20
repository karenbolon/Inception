FROM debian:bullseye

#install nginx and openssl for TLS
RUN apt update && apt upgrade -y && \
	apt install -y nginx openssl \
	&& rm -rf /var/lib/apt/lists/*

#copy nginx configuration from host machine to docker container
COPY srcs/requirements/nginx/conf/nginx.conf /etc/nginx/nginx.conf
COPY secrets/nginx.key /etc/nginx/ssl/nginx.key
COPY secrets/nginx.crt /etc/nginx/ssl/nginx.crt

#for for HTTP & HTTPS to allow external connections (TLS)
EXPOSE 443

#ENV DOMAIN_NAME=$DOMAIN_NAME

#start NGINX in the foreground, daemon off so container 
#doesn't exit abruptly when powered on
CMD  ["nginx", "-g", "daemon off;"]
