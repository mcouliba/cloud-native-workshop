'use strict';

var gulp = require('gulp');
var gulpNgConfig = require('gulp-ng-config');
const coolstoreConfig = require('./config/coolstore.config.js');

var configureSetup  = {
  createModule: false,
  constants: {
    COOLSTORE_CONFIG: coolstoreConfig
  }
};

gulp.task('config', function() {
    console.log(configureSetup);
  return gulp.src('./config/coolstore.config.json')
      .pipe(gulpNgConfig('webapp', configureSetup))
      .pipe(gulp.dest('app')); 
});