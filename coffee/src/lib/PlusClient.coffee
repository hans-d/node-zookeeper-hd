path = require 'path'

_ = require 'underscore'
async = require 'async'

{SimpleClient} = require '..'


###
  Wraps the SimpleClient to provide enhanced zookeeper client

  - more flexible method signatures, eg watch not required parameter
  - more functionality for action with options, eg ```createPathIfNotExists```
  - more actions, eg ```createOrUpdate```
###
module.exports = class PlusClient

  ###
    Constructs PlusClient and underlying SimpleClient.

    Does not yet connect to zookeeper, use #connect for that.

    @param [options="{root: '/'}"] Optional option
    @param options.root Root path for all zookeeper operations
  ###
  constructor: (options) ->
    @client = new SimpleClient options

  ###
    Connect to Zookeeper

    @param {Function} onReady Callback
    @param {String} onReady.err Error message in case of error
  ###
  connect: (onReady) ->
    @client.connect onReady


  ###
    Create an entry at the given path,

    Path may not yet exist.
    If parent path does not yet exist, it will result in an error unless
  ```createPathIfNotExists``` is provided.

    @param {Mixed} zkPath relative path
    @param value
    @param {Object} [options="{flags: null, createPathIfNotExists: false}"]
    @param options.flags
    @param {Boolean} options.createPathIfNotExists
    @param {Function} onReady Callback
    @param {Object} onReady.error In case of error
    @param {Object} onReady.path Created path
  ###

  create: (zkPath, value, options, onReady) ->
    # optional options
    if !onReady
      onReady = options
      options = {}

    # stay compatible with 'original' signature: ```(zkPath, value, flags, onReady)```
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


  ###
    Does given path exist.

    @param {Mixed} zkPath relative path
    @param {Object} [options="{watch: null}"]
    @param options.watch
    @param {Function} onData CallBack
    @param {Object} onData.error In case of error
    @param {Boolean} onData.exists True if path exists
    @param {Object} onData.stats ```Stat``` if path exists
  ###
  exists: (zkPath, options, onData) ->
    # optional options
    if !onData
      onData = options
      options = {}

    # stay compatible with 'original signature: ```(zkPath, watch, onData)```
    if !_.isObject options
      options = watch: options

    options = _.defaults options,
      watch: null

    @client.exists zkPath, options.watch, onData


  ###
    Get data from the given path.

    @param {Mixed} zkPath relative path
    @param {Object} [options="{watch: null, createPathIfNotExists: false}"]
    @param options.watch
    @param {Boolean} options.createPathIfNotExists
    @param {Function} onData CallBack
    @param {Object} onData.error In case of error
    @param {Object} onData.stat
    @param {String} onData.data

    TODO: return stat & data as one if callback signature has 2 arguments
  ###

  get: (zkPath, options, onData) ->
    # optional options
    if !onData
      onData = options
      options = {}

    # stay compatible with 'original' signature: ```(zkPath, watch, onData)```
    if !_.isObject options
      options = watch: options

    options = _.defaults options,
      watch: null
      createPathIfNotExists: false

    async.waterfall [

      (asyncReady) =>
        return asyncReady() unless options.createPathIfNotExists
        @createPathIfNotExists zkPath, options, asyncReady

      (asyncReady) =>
        @client.get zkPath, options.watch, asyncReady

    ], (err, stat, data) ->
        onData err, stat, data


  ###
    Get children from the given path, if ```getChildData``` is provided including their data

    @param {Mixed} zkPath relative path
    @param {Object} [options="{watch: null, createPathIfNotExists: false, getChildData: false, levels: 1}"]
    @param options.watch
    @param {Boolean} options.createPathIfNotExists
    @param {Boolean} options.getChildData
    @param {Boolean} options.levels
    @param {Function} onData CallBack
    @param {Object} onData.error In case of error
    @param {String[]} onData.children Names are relative to provided path
  ###

  getChildren: (zkPath, options, onData) ->
    # optional options
    if !onData
      onData = options
      options = {}

    # stay compatible with 'original' signature: ```(zkPath, watch, onData)```
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

        # recurse multiple levels
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


  ###
    Utility function to join path segments.

    Each segment can be a string, an array, or a nested array

    @return {String} Full path constructed of given components
  ###
  joinPath: (base, extra) ->
    @client.joinPath base, extra


  ###
    Creates full path, and any missing parents

    @param {Mixed} zkPath relative path
    @param {Object} [options="{}"]
    @param {Function} onReady CallBack
    @param {Object} onReady.error In case of error
  ###

  mkdir: (zkPath, options, onReady) ->
    # optional options
    # options currently not used, added for future use / uniform signature
    if !onReady
      onReady = options
      options = {}

    @client.mkdir zkPath, onReady


  ###
    Sets entry at given path.

    Path must exist, version must be same as current value (or -1).

    @param {Mixed} zkPath relative path
    @param {String} value Value to write
    @param version Current version, or -1 (other value will cause error)
    @param {Object} [options="{watch: null, createPathIfNotExists: false}"]
    @param {Boolean} options.createPathIfNotExists
    @param {Function} onReady CallBack
    @param {Object} onReady.error In case of error
    @param {Object} onReady.stat Updated ```stat```
  ###

  set: (zkPath, value, version, options, onReady) ->
    # optional options
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


  ###
    Explicit named method of why would want to use #mkdir
  ###
  createPathIfNotExists: (zkPath, options, onReady) ->
    if !onReady
      onReady = options
      options = {}

    @mkdir zkPath, options, onReady


  ###
    create (set) or update a value at given path

    @param {Mixed} zkPath relative path
    @param {String} value Value to write
    @param {Object} [options="{}"] Will use defaults of #set, #create, #exists
    @param {Function} onReady CallBack
    @param {Object} onReady.error In case of error
  ###
  createOrUpdate: (zkPath, value, options, onReady) ->
    # optional options
    if !onReady
      onReady = options
      options = {}

    options = _.defaults options, {}

    @exists zkPath, options, (err, exists, stat) =>
      return onReady(err) if err
      return @set zkPath, value, stat.version, onReady if exists
      @create zkPath, value, options, onReady


