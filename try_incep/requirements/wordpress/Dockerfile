FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y php-fpm php-mysqli curl

COPY www.conf /etc/php/8.2/fpm/pool.d/.
COPY wp_script.sh .
RUN chmod +x wp_script.sh

CMD ["./wp_script.sh"]