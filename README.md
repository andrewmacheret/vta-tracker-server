# vta-tracker-server

[![Build Status](https://travis-ci.org/andrewmacheret/vta-tracker-server.svg?branch=master)](https://travis-ci.org/andrewmacheret/vta-tracker-server) [![Docker Stars](https://img.shields.io/docker/stars/andrewmacheret/vta-tracker-server.svg)](https://hub.docker.com/r/andrewmacheret/vta-tracker-server/) [![Docker Pulls](https://img.shields.io/docker/pulls/andrewmacheret/vta-tracker-server.svg)](https://hub.docker.com/r/andrewmacheret/vta-tracker-server/) [![License](https://img.shields.io/badge/license-MIT-lightgray.svg)](https://github.com/andrewmacheret/vta-tracker-server/blob/master/LICENSE.md)

MySQL and REST server for providing [VTA GTFS data](http://www.vta.org/getting-around/gtfs-info/gtfs-information) in a friendly manner and current VTA bus routes using that data.

Intended for use by [andrewmacheret/vta-tracker](https://github.com/andrewmacheret/vta-tracker/).

See it running at [http://vta.andrewmacheret.com](http://vta.andrewmacheret.com).

Prereqs:
* [Node.js](https://nodejs.org/) on a linux server
* [MySQL server](https://dev.mysql.com)

Installation steps:
* Run the following commands in MySQL:

  ```
  create user gtfs@localhost identified by password 'CHOOSE A PASSWORD';
  grant FILE on *.* to gtfs@localhost;
  create database gtfs;
  ```

* `git clone <clone url>`
* `cd vta-tracker-server/`
* `npm install`
* At this point, if you have [docker](https://docker.com) then you can run `docker build -t <tag-name> .` to create a docker image
* If not:
 * `cp mysql.properties.example mysql.properties && chmod 600 mysql.properties` and edit `mysql.properties` to change the password
 * `./setup.sh` - this will do the following:
  1. Download the latest gtfs data
  1. Load that data into MySQL
 * Modify `port` in `settings.js` as needed
 * `node gtfs-server.js`

Note: This data changes on a quarterly basis. `./setup.sh` should be run during between quarters, perhaps with a cron job.
* A future enhancement would be to run the `./setup.sh` on an `end_date` value in the `/calendar` API.

Test it:
* `curl 'http://localhost'`.
 * This should give a list of available APIs.
* `curl 'http://localhost/agencies'`.
 * This should return a JSON representing the VTA as an agency.
* `curl 'http://localhost/find_routes'`.
 * This should give the currently active routes and is used by [andrewmacheret/vta-tracker](https://github.com/andrewmacheret/vta-tracker/).
