module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-bumpup'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-banner'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

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
      unit:
        options:
          reporter: 'spec'
          require: 'coffee-script'
        src: ['test/unit/*.coffee']

    bumpup:
      options:
        updateProps:
          pkg: 'package.json'
      file: 'package.json'

    clean:
      build:
        options:
          no-write: true
        src: ['index.js*', 'lib/*']

    usebanner:
      compiled_coffee:
        options:
          position: 'top'
          banner: '// This file has been generated from coffee source files\n'
        files:
          src: ['index.js', 'lib/*.js' ]

  grunt.registerTask 'default', [ 'test', 'build' ]
  grunt.registerTask 'test', [ 'mochaTest' ]
  grunt.registerTask 'build', [ 'clean', 'compile' ]
  grunt.registerTask 'compile', [ 'compile:coffee' ]
  grunt.registerTask 'compile:coffee', [ 'coffee', 'usebanner:compiled_coffee' ]

  grunt.registerTask 'release:bump', (type) ->
    type = type || 'patch'
    grunt.task.run 'bumpup:' + type
