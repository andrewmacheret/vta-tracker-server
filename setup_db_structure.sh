#!/bin/sh

user="$( echo $( awk -F'=' '$1~"user" {print $2}' mysql.properties ) )"
password="$( echo $( awk -F'=' '$1~"password" {print $2}' mysql.properties ) )"
database="$( echo $( awk -F'=' '$1~"database" {print $2}' mysql.properties ) )"
host="$( echo $( awk -F'=' '$1~"host" {print $2}' mysql.properties ) )"

create_db_and_user_sql="
create database ${database};
create user '${user}'@'${host}' identified with mysql_native_password;
set password for '${user}'@'${host}' = password('${password}');
grant file on *.* to '${user}'@'${host}';
grant all privileges on ${database}.* TO '${user}'@'${host}' with grant option;
"

echo
echo "Creating user and database..."
echo "${create_db_and_user_sql}" | mysql --verbose || exit 1


stupid() {
  table=$( echo "$1" | sed -r 's:^.*/([^/.]+).txt:\1:' )

  echo "drop table if exists ${table}; create table ${table} ( "
  head -1 $1 | sed -e 's/,/ varchar(255),\n/g' | sed 's/"//g'
  echo " varchar(255) );"
}


(
for file in $(ls data/*.txt); do
  stupid $file
  echo
done
) > /tmp/create_gtfs.sql

echo
echo "Creating tables..."
mysql --defaults-extra-file=mysql.properties --verbose < /tmp/create_gtfs.sql || exit 1

rm /tmp/create_gtfs.sql

