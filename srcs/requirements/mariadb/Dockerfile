FROM debian:bullseye

#removes the var directory to reduce image size
RUN apt update && apt upgrade -y && \
	apt install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

#default port for MariaDB
EXPOSE 3306

#configure MariaDB by copying initialization script from host to container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb_script.sh /usr/local/bin/mariadb_script.sh

RUN chmod +x /usr/local/bin/mariadb_script.sh

#Start MariaDB with init file
#ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh" ]

#start MariaDB in the foreground
CMD ["/usr/local/bin/mariadb_script.sh"]


