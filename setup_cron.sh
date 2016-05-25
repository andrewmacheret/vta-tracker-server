#!/bin/sh

basedir="$( dirname $0 )"
(crontab -l 2>/dev/null ; echo "0 0 * * * '${basedir}/setup.sh'") | crontab -
