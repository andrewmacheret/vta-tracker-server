#!/bin/bash

npm install express
npm install body-parser
npm install mysql
npm install moment-timezone
npm install properties-reader

./download_data.sh
./setup_structure.sh
./setup_data.sh

