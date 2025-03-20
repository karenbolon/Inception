FROM debian:bullseye

#use procps for process control
RUN apt update && apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*

#default port for MariaDB
EXPOSE 3306

#Ensure mMariaDB has proper permissions before copying the mariadb_script.sh
#RUN mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && \
	#create log file
#	touch	/var/log/mysql/mariadb.log && \
#	chown -R mysql:mysql /run/mysqld /var/log/mysql/mariadb.log /var/lib/mysql && \
#	chmod 755 /run/mysqld /var/lib/mysql && \
#	chmod 644 /var/log/mysql/mariadb.log

#configure MariaDB by copying initialisation script from host to container
COPY srcs/requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY srcs/requirements/mariadb/tools/mariadb_init.sh /bin/

RUN chmod +x /bin/mariadb_init.sh

#start MariaDB in the foreground per the script
CMD [ "/bin/mariadb_init.sh", "mysqld_safe" ]