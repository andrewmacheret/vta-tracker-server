#!/bin/sh
# pass in the file name as an argument: ./mktable filename.csv


stupid() {
  table_name=$( echo "$1" | sed -r 's:^.*/([^/.]+).txt:\1:' )

  echo "drop table if exists ${table_name}; create table ${table_name} ( "
  head -1 $1 | sed -e 's/,/ varchar(255),\n/g' | sed 's/"//g'
  echo " varchar(255) );"
}


(
for file in $(ls data/*.txt); do
  stupid $file
  echo
done
) > /tmp/create_gtfs.sql

mysql --defaults-extra-file=mysql.properties --verbose < /tmp/create_gtfs.sql

rm /tmp/create_gtfs.sql

