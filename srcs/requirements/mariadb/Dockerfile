FROM debian:bullseye

#procps is for process control
RUN apt update && apt upgrade -y && \
	apt install -y mariadb-server procps && \
	rm -rf /var/lib/apt/lists/*

#default port for MariaDB
EXPOSE 3306

#configure MariaDB by copying initialization script from host to container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb_script2.sh /usr/local/bin/mariadb_script.sh

COPY tools/mariadb_script.sh /usr/local/bin/mariadb_script.sh

RUN chmod +x /usr/local/bin/mariadb_script.sh

#start MariaDB in the foreground
ENTRYPOINT ["/usr/local/bin/mariadb_script.sh"]


