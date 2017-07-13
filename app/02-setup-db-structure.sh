#!/usr/bin/env bash
set -e

# store password for root
sed -i'' 's/^password = .*$/password = '"${MYSQL_ROOT_PASSWORD}"'/' mysql-root.properties

# generate random password for gtfs
password="$( tr -cd '[:alnum:]' < /dev/urandom | fold -w 16 | head -1 )"
sed -i'' 's/^password = .*$/password = '"$password"'/' mysql-gtfs.properties

# get gtfs properties
user="$(     echo $( awk -F'=' '$1~"user"     {print $2}' mysql-gtfs.properties ) )"
password="$( echo $( awk -F'=' '$1~"password" {print $2}' mysql-gtfs.properties ) )"
database="$( echo $( awk -F'=' '$1~"database" {print $2}' mysql-gtfs.properties ) )"
host="%"

# query to create the gtfs user
create_db_and_user_sql="
  create database if not exists ${database};
  create user if not exists '${user}'@'${host}' identified with mysql_native_password;
  set password for '${user}'@'${host}' = password('${password}');
  grant file on *.* to '${user}'@'${host}';
  grant all privileges on ${database}.* TO '${user}'@'${host}' with grant option;
  flush privileges;
"

# create the gtfs user
echo
echo "Creating database and user..."
echo "${create_db_and_user_sql}" | mysql --defaults-extra-file=mysql-root.properties

if [ ! -f data/dump.sql ]; then

  stupid1() {
    table=$( echo "$1" | sed -r 's:^.*/([^/.]+).txt:\1:' )

    echo "drop table if exists ${table}; create table ${table} ( "
    head -1 $1 | sed -e 's/,/ varchar(255),\n/g' | sed 's/"//g'
    echo " varchar(255) );"
  }

  (
    set -e
    for file in $(ls data/*.txt); do
      stupid1 $file
      echo
    done
  ) > /tmp/create-gtfs.sql

  echo
  echo "Creating tables..."
  mysql --defaults-extra-file=mysql-gtfs.properties --verbose < /tmp/create-gtfs.sql

  rm /tmp/create-gtfs.sql


  stupid2() {
    file="$1"
    table_name=$( echo "$file" | sed -r 's:^.*/([^/.]+).txt:\1:' )

    echo "TRUNCATE TABLE ${table_name}; LOAD DATA LOCAL INFILE '${file}' IGNORE INTO TABLE ${table_name} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\\n' IGNORE 1 LINES;"
  }

  (
    set -e
    for file in $(ls data/*.txt); do
      stupid2 $file
      echo
    done
  ) > /tmp/load-data-gtfs.sql

  echo
  echo "Loading gtfs data..."
  mysql --defaults-extra-file=mysql-gtfs.properties --verbose --local-infile < /tmp/load-data-gtfs.sql
  echo
  echo "Running extra sql..."
  mysql --defaults-extra-file=mysql-gtfs.properties --verbose --local-infile < find-routes.sql

  rm /tmp/load-data-gtfs.sql

  echo
  echo "Dumping database to data/dump.sql"
  mysqldump --defaults-extra-file=mysql-root.properties "$database" > data/dump.sql

else

  echo
  echo "Restoring database from data/dump.sql"
  mysql --defaults-extra-file=mysql-gtfs.properties < data/dump.sql

fi


echo
echo "Done!"

