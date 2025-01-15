FROM debian:bullseye

#removes the var directory to reduce image size
RUN apt update && apt upgrade -y && \
	apt install -y mariadb-server procps && \
	rm -rf /var/lib/apt/lists/*

#default port for MariaDB
EXPOSE 3306

#configure MariaDB
COPY /conf/50-server.cnf /etc/mysql/mariadb.conf.d/.
#COPY init.sql /etc/mysql/init.sql
COPY /tools/mariadb_script.sh /usr/local/bin/.

RUN chmod +x /usr/local/bin/mariadb_script.sh

RUN mkdir /run/mysqld

#Start MariaDB with init file
ENTRYPOINT ["/usr/local/bin/mariadb_script.sh" ]




