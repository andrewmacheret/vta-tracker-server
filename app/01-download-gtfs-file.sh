#!/usr/bin/env bash
set -e

url="$( python get-data-url.py )"
workdir="/store/$( basename "$url" )"

echo
echo "Creating symlink data -> $workdir/data"
ln -s "$workdir/data" data

if [ ! -f "$workdir/data/.data-prepared" ]; then
  
  mkdir -p "$workdir"
  cd "$workdir"

  echo
  echo "Downloading $url to $workdir/raw-data.zip" 
  wget -O raw-data.zip "$url"

  echo
  echo "Extracting $workdir/raw-data.zip to $workdir/data" 
  rm -rf data
  unzip raw-data.zip -d data
  rm raw-data.zip
  
  echo
  echo "Performing dos2unix on $workdir/data/*.txt" 
  dos2unix data/*.txt
  
  touch data/.data-prepared
else
  
  echo
  echo 'Data already downloaded and extracted'
fi


