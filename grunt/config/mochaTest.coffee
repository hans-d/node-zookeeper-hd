module.exports = {

  dir:
    base: 'test/unit'
    coffee: '<%= dir.source.coffee %>/<%= mochaTest.dir.base %>'
    js: '<%= dir.target.js %>/<%= mochaTest.dir.base %>'

  unitSpec:
    options:
      reporter: 'spec'
      require: 'coffee-script'
    src: [ '<%= mochaTest.dir.coffee %>/*.coffee' ]
  unitDot:
    options:
      reporter: 'dot'
      require: 'coffee-script'
    src: [ '<%= mochaTest.dir.coffee %>/*.coffee' ]
  unitJS:
    options:
      reporter: 'dot'
      require: 'grunt/blanketJS'
    src: [ '<%= mochaTest.dir.js %>/*.js' ]
  coverageJS:
    options:
      reporter: 'html-cov'
      quiet: true
      captureFile: 'coverageJS.html'
    src: [ '<%= mochaTest.dir.js %>/*.js' ]



}
