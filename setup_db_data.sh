#!/bin/sh
# pass in the file name as an argument: ./mktable filename.csv

basedir=$( dirname "$0" )

stupid() {
  file="$1"
  table_name=$( echo "$file" | sed -r 's:^.*/([^/.]+).txt:\1:' )


  echo "TRUNCATE TABLE ${table_name}; LOAD DATA LOCAL INFILE '${file}' IGNORE INTO TABLE ${table_name} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\\n' IGNORE 1 LINES;"
}

(
for file in $(ls data/*.txt); do
  stupid $file
  echo
done
) > /tmp/load_data_gtfs.sql

(
  cd "$basedir"
  echo
  echo "Loading gtfs data..."
  mysql --defaults-extra-file=mysql.properties --verbose --local-infile < /tmp/load_data_gtfs.sql || exit 1
  echo
  echo "Running extra sql..."
  mysql --defaults-extra-file=mysql.properties --verbose --local-infile < find_routes.sql || exit 1
) || exit 1

rm /tmp/load_data_gtfs.sql

echo
echo "Done!"
