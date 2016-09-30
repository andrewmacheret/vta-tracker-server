#!/bin/bash -e

url="$( python get-data-url.py )"

wget -O raw-data.zip "$url"

rm -rf data

unzip raw-data.zip -d data

rm raw-data.zip

dos2unix data/*.txt
