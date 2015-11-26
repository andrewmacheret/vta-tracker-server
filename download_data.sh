#!/bin/bash

basedir="$( dirname "$0" )"

url="$( python get_data_url.py )" || exit 1

wget -O "$basedir"/raw_data.zip "$url" || exit 1

rm -rf "$basedir"/data

unzip "$basedir"/raw_data.zip -d "$basedir"/data || exit 1

rm "$basedir"/raw_data.zip || exit 1

dos2unix "$basedir"/data/*.txt


