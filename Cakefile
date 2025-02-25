fs = require 'fs'
browserify = require 'browserify'
UglifyJS = require 'uglify-js'
Promise = require 'bluebird'
{spawn, exec} = require 'child_process'
util = require 'util'

writeFile = (dest, src) ->
  new Promise (resolve, reject) ->
    fs.writeFile dest, src, ->
      fs.stat dest, (err, stats) ->
        return reject(err) if err?
        console.log "Wrote #{dest} - #{Math.round(stats.size / 1024)}KB"
        resolve()

task 'compile-browser', 'Compile with browserify for the web', ->
  browserify
    noParse: [
      'fs'
    ]
    transform: [
      ['browserify-shim', { "lodash": "global:_lodash" }]
    ]
  .transform('coffeeify')
  .require('./shims/png.coffee', expose: './image_exports/png.coffee')
  .require('./shims/init.coffee', expose: './psd/init.coffee')
  .require('./lib/psd.coffee', expose: 'psd')
  .bundle (err, src, map) ->
    return console.log(err) if err?
    writeFile('./dist/psd.js', src)
      .then ->
        minSrc = UglifyJS.minify './dist/psd.js',
          outSourceMap: 'psd.js.map'
          sourceRoot: '/'

        writeFile './dist/psd.min.js', minSrc.code
        minSrc
      .then (minSrc) ->
        writeFile './dist/psd.js.map', minSrc.map
      .then ->
        # jsContent = fs.readFileSync './dist/psd.js', (err, data) ->
        jsContent = fs.readFileSync './dist/psd.min.js', (err, data) ->
          return reject(err) if err?
        # writeFile './dist/psd.umd.js', jsContent.toString().replace('require=', 'export default (').slice(0, -2) + "('psd'))"
        writeFile './dist/psd.umd.js', 'window._ = require(\'lodash\')\r\nwindow.fs = require(\'fs\')\r\n' +  jsContent.toString().replace('require=', 'export default (').replace(";\n//# sourceMappingURL=psd.js.map","('psd'));\n//# sourceMappingURL=psd.js.map")
      .then ->
        console.log 'Finished!'

task 'docs:generate', 'Generate documentation', ->
  npm = spawn 'npm', ['run-script', 'docs']
  npm.stdout.pipe(process.stdout)
  npm.stderr.pipe(process.stderr)

task 'docs:deploy', 'Deploys updated documentation to GitHub Pages', ->
  console.log 'Switching to gh-pages'
  exec 'git checkout gh-pages', (err) ->
    return console.log(err) if err?
    console.log 'Checking out docs from master'
    exec 'git checkout master docs', (err) ->
      return console.log(err) if err?
      console.log 'Committing new documentation'
      exec 'git commit -a -m "Update documentation"', (err) ->
        return console.log(err) if err?
        console.log 'Pushing to GitHub...'
        exec 'git push origin gh-pages', (err) ->
          return console.log(err) if err?
          console.log 'Switching back to master'
          exec 'git checkout master', (err) ->
            return console.log(err) if err?
            console.log 'Deployed!'
