# vta-tracker-server

[![Build Status](https://travis-ci.org/andrewmacheret/vta-tracker-server.svg?branch=master)](https://travis-ci.org/andrewmacheret/vta-tracker-server) [![Docker Stars](https://img.shields.io/docker/stars/andrewmacheret/vta-tracker-server.svg)](https://hub.docker.com/r/andrewmacheret/vta-tracker-server/) [![Docker Pulls](https://img.shields.io/docker/pulls/andrewmacheret/vta-tracker-server.svg)](https://hub.docker.com/r/andrewmacheret/vta-tracker-server/) [![License](https://img.shields.io/badge/license-MIT-lightgray.svg)](https://github.com/andrewmacheret/vta-tracker-server/blob/master/LICENSE.md)

MySQL and REST server for providing [VTA GTFS data](http://www.vta.org/getting-around/gtfs-info/gtfs-information) in a friendly manner and current VTA bus routes using that data.

Intended for use by [andrewmacheret/vta-tracker](https://github.com/andrewmacheret/vta-tracker/).

See it running at [https://andrewmacheret.com/projects/vta-tracker](https://andrewmacheret.com/projects/vta-tracker).

## Docker usage:

Prereqs:

* [Node.js](https://nodejs.org/) on a linux server

* [Docker](https://www.docker.com/products/docker)

Usage:

```bash
# install node prerequisites
cd app/
npm install

# set a mysql root password
export MYSQL_ROOT_PASSWORD='some-password'

# start a mysql server, don't publish a port
docker run -d \
  --name mysql \
  --env "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" \
  mysql:5.7

# start vta-tracker-server once the mysql server is up and running (probably takes within 5 seconds)
docker run -d \
  --name vta-tracker-server \
  -p 80:80 \
  --link mysql:mysql \
  --env "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" \
  andrewmacheret/vta-tracker-server
```

## Manual usage:

Prereqs:

* [MySQL server](https://dev.mysql.com) - requires minimum of 5.7, although you can get it working in 5.6 if you fix compatibility issues in [02-setup-db-structure.sh](app/02-setup-db-structure.sh))

* [Node.js](https://nodejs.org/)

* bash, python (both come with most linux distros)

Usage:

```bash
# install node prerequisites
cd app/
npm install

# modify mysql.properties with your mysql root credentials with your preferred editor
nano mysql.properties
# recommended you also change permissions on this file
chmod 600 mysql.properties

# run all setup steps (download gtfs data, create gtfs user and database, and set up cron for the current user)
./setup.sh

# start the gtfs server
node gtfs-server.js
```

You can modify the port in [settings.js](app/settings.js).

## Test it out:

* `curl 'http://localhost'`.
  * This should give a list of available APIs.
* `curl 'http://localhost/agencies'`.
  * This should return a JSON representing the VTA as an agency.
* `curl 'http://localhost/find_routes'`.
  * This should give the currently active routes and is used by [andrewmacheret/vta-tracker](https://github.com/andrewmacheret/vta-tracker/).
