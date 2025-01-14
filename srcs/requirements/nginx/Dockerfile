FROM debian:bullseye

#install nginx and openssl for TLS
RUN apt update && apt upgrade -y
RUN	apt install -y nginx openssl
RUN rm -rf /var/lib/apt/lists/*

#copy static website files and nginx configuration
#COPY tools/index.html /usr/share/nginx/html
#COPY tools/index.php /usr/share/nginx/html
COPY conf/default.conf /etc/nginx/default.conf

#TSL setup
#RUN mkdir -p /etc/nginx/ssl
#RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/nginx_inception.crt -keyout /etc/nginx/ssl/nginx_inception.key -subj "/CN=kbolon.42.fr"
#RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/inception.crt       -keyout /etc/nginx/ssl/inception.key       -subj "/CN=localhost/UID=login"

# expose HTTP and HTTPS ports to allow external connections
EXPOSE 443

# start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

#for TLS use port 443 and 80
EXPOSE 443

#start NGINX in the foreground, daemon off so container 
#doesn't exit abruptly when powered on
CMD  ["nginx", "-g", "daemon off;"]

