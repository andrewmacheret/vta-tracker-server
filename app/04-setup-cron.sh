#!/bin/bash -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
basedir="$( pwd )"

(echo "0 0 * * * '${basedir}/setup.sh'") | crontab -
