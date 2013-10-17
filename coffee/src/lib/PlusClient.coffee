SimpleClient = require './SimpleClient'
_ = require 'underscore'
async = require 'async'
path = require 'path'

module.exports = class PlusClient

  constructor: (options) ->
    @client = new SimpleClient options

  connect: (onReady) ->
    @client.connect onReady

  create: (zkPath, value, options, onReady) ->
    if !onReady
      onReady = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      options = flags: options
    options = _.defaults options,
      flags: null
      createPathIfNotExists: false

    async.waterfall [

      (asyncReady) =>
        return asyncReady() unless options.createPathIfNotExists
        @createPathIfNotExists path.dirname(zkPath), options, asyncReady

      (asyncReady) =>
        @client.create zkPath, value, options.flags, asyncReady

    ], (err, path) ->
        onReady err, path


  exists: (zkPath, options, onData) ->
    if !onData
      onData = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      options = watch: options
    options = _.defaults options, watch: null

    @client.exists zkPath, options.watch, onData


  get: (zkPath, options, onData) ->
    if !onData
      onData = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      options = watch: options
    options = _.defaults options,
      watch: null
      createPathIfNotExists: false

    # TODO: return stat & data as one if callback signature has 2 arguments

    async.waterfall [

      (asyncReady) =>
        return asyncReady() unless options.createPathIfNotExists
        @createPathIfNotExists zkPath, options, asyncReady

      (asyncReady) =>
        @client.get zkPath, options.watch, asyncReady

    ], (err, stat, data) ->
        onData err, stat, data


  getChildren: (zkPath, options, onData) ->
    if !onData
      onData = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
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
      onReady = options
      options = {}

    @client.mkdir zkPath, onReady


  set: (zkPath, value, version, options, onReady) ->
    # options currently not used, added for future use / uniform signature
    if !onReady
      onReady = options
      options = {}

    options = _.defaults options,
      createPathIfNotExists: false

    async.waterfall [

      (asyncReady) =>
        return asyncReady() unless options.createPathIfNotExists
        @createPathIfNotExists zkPath, options, asyncReady

      (asyncReady) =>
        @client.set zkPath, value, version, asyncReady

    ], (err, stat) ->
      onReady err, stat


  createPathIfNotExists: (zkPath, options, onReady) ->
    if !onReady
      onReady = options
      options = {}

    @mkdir zkPath, options, onReady

  createPathIfNotExist: (zkPath, options, onReady) ->
    # Backward compatible
    createPathIfNotExists zkPath, options, onReady

  createOrUpdate: (zkPath, value, options, onReady) ->
    # for backward compatability added extraArg
    # old signature: zkPath, value, flags, watch, onReady
    # will be deprecated in future version
    if !onReady
      onReady = options
      options = {}
    # stay compatible with original signature
    if !_.isObject options
      options = flags: options, watch: onReady
      onReady = arguments[4]
    options = _.defaults(options, flags: null, watch: null)

    @exists zkPath, options, (err, exists, stat) =>
      return onReady(err) if err
      return @set zkPath, value, stat.version, onReady if exists
      @create zkPath, value, options, onReady


