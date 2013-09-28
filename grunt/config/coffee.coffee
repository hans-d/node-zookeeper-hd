module.exports = {

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


}
