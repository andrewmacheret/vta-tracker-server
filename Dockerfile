FROM ubuntu:latest

# Install dependencies
RUN apt-get autoclean
RUN apt-get update -y
RUN apt-get install -y nodejs
RUN echo mysql-server mysql-server/root_password password strangehat | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password strangehat | debconf-set-selections
RUN apt-get install -y mysql-server
RUN apt-get install -y python-bs4
RUN apt-get install -y wget unzip dos2unix

# Slim down the container
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Weird mysql setup steps
RUN usermod -d /var/lib/mysql/ mysql
RUN sed -i'' 's/password=/authentication_string=/g' /usr/share/mysql/debian-start.inc.sh
ENV MYSQL_PWD strangehat

# Set work dir
WORKDIR /app

# Setup mysql.properties
COPY . .
RUN cp mysql.properties.example mysql.properties && chmod 600 mysql.properties

# Expose node port
EXPOSE 80

# Run mysql, setup.sh, and node
CMD service mysql start && \
    ./setup.sh && \
    /usr/bin/nodejs /app/gtfs-server.js
