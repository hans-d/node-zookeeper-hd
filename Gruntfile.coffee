shell = require 'shelljs'

runSilent = (cmd) ->
  shell.exec cmd, silent: true

run = (cmd) ->
  shell.exec cmd

runSimple = (cmd) ->
  res = runSilent cmd
  return false unless res.code == 0


module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-bumpup'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.initConfig
    pkgFile : 'package.json'
    pkg: grunt.file.readJSON 'package.json'

    bumpup:
      options:
        updateProps:
          pkg: 'package.json'
      files: [ 'package.json' ]

    release:
      options:
        commitMessage: 'release <%= pkg.version %>'
        tagName: 'release-<%= pkg.version %>'
        tagMessage: 'release <%= pkg.version %>'


  grunt.registerTask 'release:prep', [ 'git:isClean', 'semver:isSynced' ]

  grunt.registerTask 'release:bump', (type) ->
    type = type || 'patch'
    grunt.task.run 'bumpup:' + type

  grunt.registerTask 'release:commit', [ 'git:add:package.json', 'git:commit:release', 'git:tag:release' ]

  grunt.registerTask 'release:patch', [ 'release:prep', 'release:bump:patch', 'release:commit' ]

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
