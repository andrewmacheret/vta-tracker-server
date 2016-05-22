FROM ubuntu:latest

# Install dependencies
RUN apt-get update -y
RUN apt-get install -y nodejs npm
RUN echo mysql-server mysql-server/root_password password strangehat | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password strangehat | debconf-set-selections
RUN apt-get install -y mysql-server
RUN apt-get install -y python-bs4
RUN apt-get install -y wget unzip dos2unix

# Weird mysql setup steps
RUN usermod -d /var/lib/mysql/ mysql
RUN sed -i'' 's/password=/authentication_string=/g' /usr/share/mysql/debian-start.inc.sh
ENV MYSQL_PWD strangehat

# Add user noder and go into home directory
RUN useradd -m -s /usr/bin/false noder
ADD . /home/noder/gtfs
WORKDIR /home/noder/gtfs

# Setup gtfs
RUN cp mysql.properties.example mysql.properties
RUN chmod 600 mysql.properties
RUN service mysql start && \
  mysql -sNe "\
create database gtfs;\
create user gtfs@localhost identified with mysql_native_password;\
set password for 'gtfs'@'localhost' = password('CHOOSE_A_PASSWORD');\
grant file on *.* to gtfs@localhost;\
grant all privileges on gtfs.* TO 'gtfs'@'localhost' with grant option;\
" && \
  ./setup.sh

# Expose node port
EXPOSE 3002

# Run node
CMD service mysql start && /usr/bin/nodejs /home/noder/gtfs/gtfs-server.js
