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
  grunt.registerTask 'test:coverage', [ 'mochaTest:unitJS', 'mochaTest:coverageJS' ]
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
        src: [ 'js/*' ]

    coffee:
      compile:
        options:
          bare: true
          sourceMap: true
        files: [
          expand: true
          flatten: false
          cwd: 'coffee'
          src: ['**/*.coffee']
          dest: 'js'
          ext: '.js'
        ]

    mochaTest:
      unitSpec:
        options:
          reporter: 'spec'
          require: 'coffee-script'
        src: ['coffee/test/unit/*.coffee']
      unitDot:
        options:
          reporter: 'dot'
          require: 'coffee-script'
        src: ['coffee/test/unit/*.coffee']
      unitJS:
        options:
          reporter: 'dot'
          require: 'grunt/blanketJS'
        src: ['js/test/unit/*.js']
      coverageJS:
        options:
          reporter: 'html-cov'
          quiet: true
          captureFile: 'coverageJS.html'
        src: ['js/test/unit/*.js']

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
          src: [ 'js/**/*.js' ]

  grunt.registerTask 'release:prep', [ 'git:isClean', 'semver:isSynced', 'build', 'test', 'git:isClean' ]

  grunt.registerTask 'release:commit', [ 'git:add:package.json', 'git:commit:release', 'git:tag:release' ]

  grunt.registerTask 'release:patch', [ 'release:prep', 'semver:bump:patch', 'release:commit' ]
  grunt.registerTask 'release:minor', [ 'release:prep', 'semver:bump:minor', 'release:commit' ]
  grunt.registerTask 'release:major', [ 'release:prep', 'semver:bump:major', 'release:commit' ]

  grunt.registerTask 'release:push', ['git:push', 'git:pushTags' ]
  grunt.registerTask 'release:publish', ['release:push', 'npm:publish' ]


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

  grunt.registerTask 'git:push', ->
    return runSimple 'git push'

  grunt.registerTask 'git:pushTags', ->
    return runSimple 'git push --tags'

  grunt.registerTask 'git:tag:release', ->
    tag = grunt.config 'release.options.tagName'
    msg = grunt.config 'release.options.tagMessage'
    return runSimple "git tag  #{tag} -m '#{msg}'"


  grunt.registerTask 'npm:publish', (tag) ->
    tag = tag || ''
    tag = ' -- tag ' + tag if tag
    return runSimple "npm publish #{tag}"

  grunt.registerTask 'semver:bump', (type) ->
    type = type || 'patch'
    grunt.task.run 'bumpup:' + type

  grunt.registerTask 'semver:isSynced', ->
    res = runSilent "node_modules/.bin/semver-sync --verify"
    return false unless res.code == 0
    if res.code == 0
      grunt.log.writeln res.output
      return
    grunt.error res.output
    return false


# release:
# bump, stage+commit+tag+push, publish
