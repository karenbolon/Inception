FROM debian:bullseye

#install nginx and openssl for TLS
RUN apt update && apt upgrade -y
RUN	apt install -y nginx openssl
RUN rm -rf /var/lib/apt/lists/*

#copy static website files and nginx configuration
#COPY tools/index.html /usr/share/nginx/html
#COPY tools/index.php /usr/share/nginx/html
COPY conf/default.conf /etc/nginx/default.conf

#for TLS use port 443 and 80
EXPOSE 443

#start NGINX in the foreground, daemon off so container 
#doesn't exit abruptly when powered on
CMD  ["nginx", "-g", "daemon off;"]

