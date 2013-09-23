shell = require 'shelljs'

runSilent = (cmd) ->
  shell.exec cmd, silent: true

run = (cmd) ->
  shell.exec cmd

runSimple = (cmd) ->
  res = runSilent cmd
  return false unless res.code == 0


module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-banner'
  grunt.loadNpmTasks 'grunt-bumpup'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', [ 'test', 'build' ]
  grunt.registerTask 'test', [ 'mochaTest:unitDot' ]
  grunt.registerTask 'test:spec', [ 'mochaTest:unitSpec' ]
  grunt.registerTask 'build', [ 'clean', 'compile' ]
  grunt.registerTask 'compile', [ 'compile:coffee' ]
  grunt.registerTask 'compile:coffee', [ 'coffee', 'usebanner:compiled_coffee' ]

  grunt.initConfig
    pkgFile : 'package.json'
    pkg: grunt.file.readJSON 'package.json'

    bumpup:
      options:
        updateProps:
          pkg: 'package.json'
      files: [ 'package.json' ]

    clean:
      build:
        options:
        no-write: true
        src: ['index.js*', 'lib/*']

    coffee:
      compile:
        options:
          bare: true
          sourceMap: true
        files: [
          expand: true
          flatten: false
          cwd: 'src'
          src: ['*.coffee', 'lib/*.coffee']
          dest: ''
          ext: '.js'
        ]

    mochaTest:
      unitSpec:
        options:
          reporter: 'spec'
          require: 'coffee-script'
        src: ['test/unit/*.coffee']
      unitDot:
        options:
          reporter: 'dot'
          require: 'coffee-script'
        src: ['test/unit/*.coffee']

    release:
      options:
        commitMessage: 'release <%= pkg.version %>'
        tagName: 'release-<%= pkg.version %>'
        tagMessage: 'release <%= pkg.version %>'

    usebanner:
      compiled_coffee:
        options:
          position: 'top'
          banner: '// This file has been generated from coffee source files\n'
        files:
          src: ['index.js', 'lib/*.js' ]

  grunt.registerTask 'release:prep', [ 'git:isClean', 'semver:isSynced', 'build', 'test' ]

  grunt.registerTask 'release:bump', (type) ->
    type = type || 'patch'
    grunt.task.run 'bumpup:' + type

  grunt.registerTask 'release:commit', [ 'git:add:package.json', 'git:commit:release', 'git:tag:release' ]

  grunt.registerTask 'release:patch', [ 'release:prep', 'release:bump:patch', 'release:commit' ]


  grunt.registerTask 'git:add', (file) ->
    res = runSimple "git add #{file}"


  grunt.registerTask 'git:commit:release', ->
    msg = grunt.config 'release.options.commitMessage'
  return runSimple "git commit -m '#{msg}'"

  grunt.registerTask 'git:isClean', ->
    res = runSilent 'git status -s'
    return unless res.output
    grunt.log.error 'Uncommitted changes'
    grunt.log.writelns res.output
  return false

  grunt.registerTask 'git:tag:release', ->
    tag = grunt.config 'release.options.tagName'
    msg = grunt.config 'release.options.tagMessage'
  return runSimple "git tag  #{tag} -m '#{msg}'"

  _semverSync = 'node_modules/semver-sync/bin/semver-sync'

  grunt.registerTask 'semver:isSynced', ->
    res = runSilent "#{_semverSync} --verify"
    return false unless res.code == 0
    if res.code == 0
      grunt.log.writeln res.output
    return
    grunt.error res.output
  return false


# release:
# bump, stage+commit+tag+push, publish
