FROM debian:bullseye

#install nginx and openssl for TLS
RUN apt update && apt install -y nginx openssl curl iputils-ping\
	&& rm -rf /var/lib/apt/lists/*

#copy nginx configuration file from host machine to docker container
COPY conf/nginx.conf /etc/nginx/nginx.conf

#for HTTP & HTTPS to allow external connections (TLS)
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
