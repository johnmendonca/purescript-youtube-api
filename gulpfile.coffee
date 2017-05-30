gulp = require 'gulp'
sass = require 'gulp-sass'
connect = require 'gulp-connect'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
bower_files = require 'main-bower-files'
process = require 'child_process'
purescript = require 'gulp-purescript'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'

src   = './src/'
build = './build/'

html_src = "#{src}**/*.html"
sass_src = "#{src}sass/**/*.scss"
asset_src = "#{src}assets/**/*"
purs_src = [
  "src/**/*.purs",
  "bower_components/purescript-*/src/**/*.purs" ]

gulp.task 'server', ->
  connect.server
    root: build,
    livereload: true

gulp.task 'ie8_js', ->
  gulp.src bower_files
      filter: ["**/*respond*", "**/*shiv*"]
    .pipe concat "ie8.js"
    .pipe uglify()
    .pipe gulp.dest("#{build}js")

gulp.task 'vendor_js', ->
  gulp.src bower_files
      filter: "**/!(*respond*|*shiv*).js"
    .pipe concat "vendor.js"
    .pipe uglify()
    .pipe gulp.dest("#{build}js")

gulp.task 'assets', ->
  gulp.src asset_src
    .pipe gulp.dest("#{build}assets")
    .pipe connect.reload()

gulp.task 'sass', ->
  gulp.src sass_src
    .pipe sass(
      style: 'compressed',
      includePaths: [
        './bower_components/normalize-scss']
      ).on('error', sass.logError)
    .pipe gulp.dest("#{build}css")
    .pipe connect.reload()

gulp.task 'html', ->
  gulp.src html_src
    .pipe gulp.dest(build)
    .pipe connect.reload()

gulp.task 'psc', ->
  purescript.compile(src: purs_src)

gulp.task 'psc-bundle', ['psc'], ->
  purescript.bundle(
    src: "./output/**/*.js",
    output: "#{build}js/main.js",
    module: "Main",
    main: "Main")

gulp.task 'browserify', ['psc-bundle'], ->
  browserify("#{build}js/main.js")
    .bundle()
    .pipe source('main.js')
    .pipe buffer()
    .pipe uglify()
    .pipe gulp.dest("#{build}js/")
    .pipe connect.reload()

gulp.task 'psci', (f) ->
  process.spawn('psci', purs_src, stdio: 'inherit')
    .on('close', f)

gulp.task 'dotpsci', ->
  purescript.psci(src: purs_src)
    .pipe gulp.dest(".")

gulp.task 'watch', ->
  gulp.watch asset_src, ['assets']
  gulp.watch sass_src, ['sass']
  gulp.watch html_src, ['html']
  gulp.watch purs_src, ['browserify']

gulp.task 'build', ['ie8_js', 'vendor_js', 'assets', 'sass', 'html', 'browserify']
gulp.task 'default', ['build', 'server', 'watch']

