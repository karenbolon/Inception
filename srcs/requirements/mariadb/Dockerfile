FROM debian:bullseye

#use procps for process control
RUN apt update && apt install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

#default port for MariaDB
EXPOSE 3306

#configure MariaDB by copying initialisation script from host to container
COPY srcs/requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY srcs/requirements/mariadb/tools/mariadb_script.sh /usr/local/bin/mariadb_script.sh

RUN chmod +x /usr/local/bin/mariadb_script.sh

#start MariaDB in the foreground per the script
CMD [ "/usr/local/bin/mariadb_script.sh" ]