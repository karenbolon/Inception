FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y mariadb-server

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY init.sql /etc/mysql/init.sql
COPY mariadb_script.sh .

#mariadb runs with socket at /run/mysqld therefore we need to create the same directory
RUN mkdir /run/mysqld && chmod +x mariadb_script.sh

CMD ["./mariadb_script.sh"]