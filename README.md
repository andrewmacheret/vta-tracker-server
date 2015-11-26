# vta-tracker-server

MySQL and REST server for providing [VTA GTFS data](http://www.vta.org/getting-around/gtfs-info/gtfs-information) in a friendly manner and current VTA bus routes using that data.

Intended for use by [andrewmacheret/vta-tracker](https://github.com/andrewmacheret/vta-tracker/).

See it running at [http://vta.andrewmacheret.com](http://vta.andrewmacheret.com).

Prereqs:
* [Node.js](https://nodejs.org/) on a linux server
* [MySQL server](https://dev.mysql.com)

Installation steps:
* Run the following commands in `mysql`:
  ```sql
  create user gtfs@localhost identified by password 'CHOOSE A PASSWORD';
  grant FILE on *.* to gtfs@localhost;
  create database gtfs;
  ```
* `git clone <clone url>`
* `cd vta-tracker-server/`
* Run the following 
* `cp mysql.properties.example mysql.properties` and edit `mysql.properties` (change the password)
* `./setup.sh` - this will do the following:
 1. Install npm modules
 1. Download the latest gtfs data
 1. Load that data into MySQL
* Modify `port` in `settings.js` as needed
* `node gtfs-server.js`

Note: This data changes on a quarterly basis. `./setup.sh` should be run during between quarters, perhaps with a cron job.
* A future enhancement would be to run the `./setup.sh` on an `end_date` value in the `/calendar` API.

Test it:
* `curl 'http://localhost:3002'`.
 * This should give a list of available APIs.
* `curl 'http://localhost:3002/agencies'`.
 * This should return a JSON representing the VTA as an agency.
* `curl 'http://localhost:3002/find_routes'`.
 * This should give the currently active routes and is used by [andrewmacheret/vta-tracker](https://github.com/andrewmacheret/vta-tracker/).
