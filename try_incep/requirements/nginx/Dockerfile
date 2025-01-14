FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y nginx

COPY default.conf /etc/nginx/sites-available/.

CMD ["nginx", "-g", "daemon off;"]