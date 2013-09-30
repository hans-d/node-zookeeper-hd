SimpleClient = require './SimpleClient'
_ = require 'underscore'
async = require 'async'

class DummyLogger
  info: ->
  debug: ->

module.exports = class PlusClient

  constructor: (options) ->
    @client = new SimpleClient options
    @log = options.logger || new DummyLogger()

  create: (zkPath, value, options, onReady) ->
    if !onReady
      @log.debug 'create: no onReady argument, inserting empty options'
      onReady = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      @log.debug 'create: non object options, moving it to options.flags'
      options = flags: options
    options = _.defaults options, flags: null

    @client.create zkPath, value, options.flags, onReady


  exists: (zkPath, options, onData) ->
    if !onData
      @log.debug 'exists: no onData argument, inserting empty options'
      onData = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      @log.debug 'exists: non object options, moving it to options.watch'
      options = watch: options
    options = _.defaults options, watch: null

    @client.exists zkPath, options.watch, onData


  get: (zkPath, options, onData) ->
    if !onData
      @log.debug 'get: no onData argument, inserting empty options'
      onData = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      @log.debug 'get: non object options, moving it to options.watch'
      options = watch: options
    options = _.defaults options, watch: null

    @client.get zkPath, options.watch, onData


  getChildren: (zkPath, options, onData) ->
    if !onData
      @log.debug 'getChildren: no onData argument, inserting empty options'
      onData = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      @log.debug 'getChildren: non object options, moving it to options.watch'
      options = watch: options
    options = _.defaults options,
      watch: null
      createPathIfNotExists: false
      getChildData: false
      levels: 1

    async.waterfall [

      (asyncReady) =>
        return asyncReady() unless options.createPathIfNotExists
        @createPathIfNotExists zkPath, options, asyncReady

      (asyncReady) =>
        @client.getChildren zkPath, options.watch, asyncReady

      (children, asyncReady) =>
        return asyncReady null, children if options.levels == 1

        nestedOptions = _.extend levels: options.levels - 1, _.omit options, 'levels'
        childData = {}

        async.each children, (child, asyncChildReady) =>
          @getChildren @joinPath(zkPath, child), nestedOptions, (err, res) =>
            return asyncChildReady err if err
            childData[child] = res
            asyncChildReady null
        , (err) ->
          asyncReady err, childData

      (children, asyncReady) =>
        return asyncReady null, children unless (options.getChildData && options.levels == 1)

        childData = {}

        async.each children, (child, asyncChildReady) =>
          @get @joinPath(zkPath, child), options, (err, stat, result) ->
            return asyncChildReady err if err
            childData[child] = result
            asyncChildReady()
        , (err) ->
          asyncReady err, childData

    ], (err, result) ->
      onData err, result

  joinPath: (base, extra) ->
    @client.joinPath base, extra

  mkdir: (zkPath, options, onReady) ->
    # options currently not used, added for future use / uniform signature
    if !onReady
      @log.debug 'mkdir: no onReady argument, inserting empty options'
      onReady = options
      options = {}

    @client.mkdir zkPath, onReady


  set: (zkPath, value, version, options, onReady) ->
    # options currently not used, added for future use / uniform signature
    if !onReady
      @log.debug 'set: no onReady argument, inserting empty options'
      onReady = options
      options = {}

    @client.set zkPath, value, version, onReady

  createPathIfNotExists: (zkPath, options, onReady) ->
    if !onReady
      @log.debug 'createPathIfNotExist: no onReady argument, inserting empty options'
      onReady = options
      options = {}

    @log.info "createPathIfNotExists #{zkPath}"
    @mkdir zkPath, options, onReady

  createPathIfNotExist: (zkPath, options, onReady) ->
    # Backward compatible
    @log.info 'createPathIfNotExist deprecated - use createPathIfNotExists instead'
    createPathIfNotExists zkPath, options, onReady

  createOrUpdate: (zkPath, value, options, onReady) ->
    # for backward compatability added extraArg
    # old signature: zkPath, value, flags, watch, onReady
    # will be deprecated in future version
    if !onReady
      @log.debug 'createOrUpdate: no onReady argument, inserting empty options'
      onReady = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      @log.debug 'createOrUpdate: non object options, moving it to options.flags; onReady -> options.watch, onReady = arguments[4]'
      options = flags: options, watch: onReady
      onReady = arguments[4]
    options = _.defaults(options, flags: null, watch: null)

    @log.info "#createOrUpdate #{value} @ #{zkPath}"
    @exists zkPath, options, (err, exists, stat) =>
      return onReady(err) if err
      return @set zkPath, value, stat.version, onReady if exists
      @create zkPath, value, options, onReady


