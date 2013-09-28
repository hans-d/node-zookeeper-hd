module.exports = {

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



}
