#!/bin/bash -e

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
) > /tmp/load-data-gtfs.sql

(
  echo
  echo "Loading gtfs data..."
  mysql --defaults-extra-file=mysql-gtfs.properties --verbose --local-infile < /tmp/load-data-gtfs.sql
  echo
  echo "Running extra sql..."
  mysql --defaults-extra-file=mysql-gtfs.properties --verbose --local-infile < find-routes.sql
)

rm /tmp/load-data-gtfs.sql

echo
echo "Done!"
