gulp = require 'gulp'
sass = require 'gulp-sass'
connect = require 'gulp-connect'

src   = './src/'
build = './build/'

html_src = "#{src}*.html"
sass_src = "#{src}sass/**/*.scss"

gulp.task 'server', ->
  connect.server
    root: build,
    livereload: true

gulp.task 'sass', ->
  gulp.src sass_src
    .pipe sass().on('error', sass.logError)
    .pipe gulp.dest("#{build}css")
    .pipe connect.reload()

gulp.task 'html', ->
  gulp.src html_src
    .pipe gulp.dest(build)
    .pipe connect.reload()

gulp.task 'watch', ->
  gulp.watch sass_src, ['sass']
  gulp.watch html_src, ['html']

gulp.task 'build', ['html', 'sass']
gulp.task 'default', ['build', 'server', 'watch']

