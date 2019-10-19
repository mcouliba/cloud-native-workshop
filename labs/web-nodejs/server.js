'use strict';

const path = require("path");
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

const request = require('request');
const fs = require('fs');
const keycloakConfig = require('./config/keycloak.config.js');
const coolstoreConfig = require('./config/coolstore.config.js');
const Keycloak = require('keycloak-connect');
const cors = require('cors');
const probe = require('kube-probe');

// Environment Variables
const gulp = require('gulp'); // Load gulp
const gulpfile = require('./gulpfile'); // Loads our config task
// Kick of gulp 'config' task, which generates angular const configuration
// gulp.series(gulpfile.coolstoreConfig); 
gulp.series(gulp.task('config'))();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

// Enable CORS support
app.use(cors());

// error handling
app.use(function(err, req, res, next) {
    console.error(err.stack);
    res.status(500).send('Something bad happened!');
});

// keycloak config server
app.get('/keycloak.json', function(req, res, next) {
    res.json(keycloakConfig);
});
// coolstore config server
app.get('/coolstore.json', function(req, res, next) {
    res.json(coolstoreConfig);
});

app.use('/', express.static(path.join(__dirname, 'views')));
app.use('/app', express.static(path.join(__dirname, 'app')));
app.use('/node_modules', express.static(path.join(__dirname, 'node_modules')));

console.log("coolstore config: " + JSON.stringify(coolstoreConfig));
console.log("keycloak config: " + JSON.stringify(keycloakConfig));

// Add a health check
probe(app);

module.exports = app;