#!/usr/bin/env bash
set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

./01-download-gtfs-file.sh
./02-setup-db-structure.sh
./03-setup-cron.sh

