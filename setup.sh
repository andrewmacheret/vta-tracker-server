#!/bin/sh

./download_gtfs_file.sh || exit 1
./setup_db_structure.sh || exit 1
./setup_db_data.sh || exit 1
