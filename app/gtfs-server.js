var express = require('express');
var bodyParser = require('body-parser');
var mysql = require('mysql');
var moment = require('moment-timezone');
var app = express();
//var urlencode = require('urlencode');
app.use(bodyParser.urlencoded({extended: true}));

var path = require('path');
var propertiesReader = require('properties-reader');
var mysqlProperties = propertiesReader(path.join(__dirname, 'mysql-gtfs.properties')).path();
//var connection = mysql.createConnection(mysqlProperties.client);
var settings = require('./settings.js');

function connectSafe(callback) {
  var tryAgain = function() {
    connectSafe(callback);
  };
  
  var connection = mysql.createConnection(mysqlProperties.client);
  connection.connect(function(err) {
    if (err) {
      console.log('error when connecting to db, trying again in 1000 ms:', err);
      setTimeout(tryAgain, 1000);
      return;
    }
    callback(null, connection);
  });
  connection.on('error', function(err) {
    console.log('db error', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST') {
      tryAgain();
    } else {
      callback(err);
    }
  });
}

function send(res, json) {
  if (json.error) res.status(500);
  var msg = JSON.stringify(json);
  console.log(msg);
  res.set({
    'Content-Type': 'application/json'
  });
  res.send(msg);
}

var tables = [
  'agency', 'calendar', 'fare_attributes', 'fare_rules', 'routes', 'shapes', 'stops', 'stop_times', 'trips'
];
var apis = [];
tables.forEach(function(table) {
  apis.push('/' + table);
});
apis.push('/find_routes');

function buildUrl(req, relativeLink) {
  var protocol = req.connection.encrypted ? 'https' : 'http';
  var host = req.headers.host;
  return protocol + '://' + host + relativeLink;
}

app.get('/', function(req, res) {
  res.setHeader('Access-Control-Allow-Origin', 'https://andrewmacheret.com');
  
  var links = [];
  apis.forEach(function(api) {
    links.push(buildUrl(req, api));
  }); 
  send(res, {success: true, apis: links});
});

tables.forEach(function(table) {
  app.get('/' + table, function(req, res) { 
    res.setHeader('Access-Control-Allow-Origin', 'https://andrewmacheret.com');
    var start = parseInt(req.query._start, 10) || 0;
    var limit = parseInt(req.query._limit, 10) || 10;
    if (start < 0) start = 0;
    if (limit <= 0 || limit > 100) limit = 10;
    var args = [];
    

    var selectSql = 'select * from ' + table;
    var whereSql = '';
    var limitSql = ' limit ?,?';

    var params = {};
    Object.keys(req.query).forEach(function(key) {
      if (key.match(/^[a-zA-Z][a-zA-Z0-9_]*$/)) {
        var val = req.query[key];
        if (whereSql == '') {
          whereSql += ' where';
        } else {
          whereSql += ' and';
        }
        whereSql += ' `' + key + "` = ?";
        args.push(val);
        params[key] = val;
      }
    });
    args.push(start);
    args.push(limit);
    
    connectSafe(function(err, connection) {
      if (err) {
        send(res, {success: false, params: params, _start: start, _limit: limit, err: err});
        return;
      }
      var query = connection.query(selectSql + whereSql + limitSql, args, function(err, results, fields) {
        if (err) {
          send(res, {success: false, params: params, _start: start, _limit: limit, err: err});
          return;
        }
        send(res, {success: true, params: params, _start: start, _limit: limit, _count: results.length, results: results});
      });
      console.log(query.sql);
    });
  });
});

app.get('/find_routes', function(req, res) {
  res.setHeader('Access-Control-Allow-Origin', 'https://andrewmacheret.com');
  var time = req.query.time && moment.tz(req.query.time) || moment();
  var formattedTime = time.tz('America/Los_Angeles').format('YYYY-MM-DD HH:mm:ss');
  connectSafe(function(err, connection) {
    if (err) {
      send(res, {success: false, params: params, _start: start, _limit: limit, err: err});
      return;
    }
    var query = connection.query('call find_routes(?)', [formattedTime], function(err, results, fields) {
      if (err) {
        send(res, {success: false, time: time, err: err});
        return;
      }
      send(res, {success: true, time: time.toString(), debug: formattedTime, _count: results[0].length, results: results[0]});
    });
  });
});

var port = settings.port;
app.listen(port);
console.log('listening on ' + port);

