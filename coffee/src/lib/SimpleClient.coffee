Zookeeper = require 'zookeeper'
_ = require 'underscore'


###
  Utility function for normalizing underlying zookeeper callback and providing some
  extra detail

  @param {String} action Name of zookeeper action
  @param {Mixed} path Provided (relative) path for the action
  @param {Function} callback Callback to use

  @return {Function} Normalized callback
  @return {Integer} return.resultCode Zookeeper resultCode
  @return {String} return.error Zookeeper error message
  @return {Mixed} return.data1 Placekeeper for extra provided argument 1
  @return {Mixed} return.data2 Placekeeper for extra provided argument 2
  @return {Object} return.return Provided callback to calling method
  @return {Object} return.return.error Null if no error, otherwise
  @return {Integer} return.return.error.rc Zookeeper resultcode
  @return {String} return.return.error.msg Zookeeper error message
  @return {Mixed} return.return.error.path Path causing the error
  @return {String} return.return.error.action Action causing the error
  @return {Mixed} return.return.data1 Placekeeper for extra provided argument 1
  @return {Mixed} return.return.data2 Placekeeper for extra provided argument 2
###
normalizeCallBack = (action, path, callback) ->
  return (resultCode, error, data1, data2) ->
    return callback rc: resultCode, msg: error, path: path, action: action if resultCode != 0
    return callback null, data1 if arguments.length <= 3
    callback null, data1, data2


###
  Wraps the [zookeeper](https://github.com/yfinkelstein/node-zookeeper) module to
  normalize function names and callback signatures, and a few extras.

  Method signature are the same as for the underlying zookeeper module.

  - ```a_``` (async) prefix for function names are removed
  - callback will have a single error argument instead of 2: ```{ rc: resultCode, msg: error }```
  - constructor allows for ```root``` option to provide base root for all given paths
  - provided paths are relative to the given root, and can be String or nested String[]
  - ```joinPath``` to generate full path from given components

  TODO: watches

###
module.exports = class SimpleClient


  ###
    Constructs SimpleClient, and underlying zookeeper client

    Does not yet connect to zookeeper, use #connect for that.

    @param [options="{root: '/'}"] Optional option
    @param options.root Root path for all zookeeper operations
  ###
  constructor: (options) ->
    options = options || {}
    @client = new Zookeeper options
    @root = options.root || '/'


  ###
    Connects to zookeeper

    @param {Function} onReady Callback
    @param {String} onReady.err Error message in case of error
  ###
  connect: (onReady) ->
    @client.connect onReady


  ###
    Utility function to get the path relative to the given root

    @return {String} Absolute path including root
  ###
  fullPath: (relativePath) ->
    return @joinPath @root, relativePath


  ###
    Utility function to join path segments.

    Each segment can be a string, an array, or a nested array

    @return {String} Full path constructed of given components
  ###
  joinPath: (base, extra) ->
    all = []
    all.push base if base
    all.push extra if extra
    return (_.flatten all).join('/')
      .replace('///', '/')
      .replace '//', '/'

  ###
    Create an entry at the given path,

    The parent of the path must exist, path may not yet exist.

    @param {Mixed} zkPath relative path
    @param value
    @param flags
    @param {Function} onReady normalized callBack
    @param {Object} onReady.error In case of error
    @param {Object} onReady.path Created path
  ###
  create: (zkPath, value, flags, onReady) ->
    @client.a_create @fullPath(zkPath), value, flags, normalizeCallBack 'create', zkPath, onReady


  ###
    Does given path exist.

    Does not provide an error if the path does not exist (as the underlying client does)

    @param {Mixed} zkPath relative path
    @param watch Not yet implemented
    @param {Function} onData normalized callBack
    @param {Object} onData.error In case of error
    @param {Boolean} onData.exists True if path exists
    @param {Object} onData.stats ```Stat``` if path exists
  ###
  exists: (zkPath, watch, onData) ->
    @client.a_exists @fullPath(zkPath), watch, (resultCode, error, stat) ->
      return onData null, true, stat if resultCode == 0
      return onData null, false  if error == 'no node'
      onData msg: error, rc: resultCode, action: 'exists', path: zkPath, false


  ###
    Get data from the given path.

    @param {Mixed} zkPath relative path
    @param watch Not yet implemented
    @param {Function} onData normalized callBack
    @param {Object} onData.error In case of error
    @param {Object} onData.stat
    @param {String} onData.data
  ###
  get: (zkPath, watch, onData) ->
    @client.a_get @fullPath(zkPath), watch, normalizeCallBack 'get', zkPath, onData


  ###
    Get children from the given path.

    @param {Mixed} zkPath relative path
    @param watch Not yet implemented
    @param {Function} onData normalized callBack
    @param {Object} onData.error In case of error
    @param {String[]} onData.children Names are relative to provided path
  ###
  getChildren: (zkPath, watch, onData) ->
    @client.a_get_children @fullPath(zkPath), watch, normalizeCallBack 'getChildren', zkPath, onData


  ###
    Creates full path, and any missing parents

    Function is client specific, and is not an original zookeeper action.

    @param {Mixed} zkPath relative path
    @param {Function} onReady normalized callBack
    @param {Object} onReady.error In case of error
  ###
  mkdir: (zkPath, onReady) ->
    # NB: callback is different!
    @client.mkdirp @fullPath(zkPath), (err) ->
      return onReady msg: err, rc: null, action: 'mkdir', path: zkPath if err
      onReady()

  ###
    Sets entry at given path.

    Path must exist, version must be same as current value (or -1).

    @param {Mixed} zkPath relative path
    @param {String} value Value to write
    @param version Current version, or -1 (other value will cause error)
    @param {Function} onReady normalized callBack
    @param {Object} onReady.error In case of error
    @param {Object} onReady.stat Updated ```stat```
  ###
  set: (zkPath, value, version, onReady) ->
    @client.a_set @fullPath(zkPath), value, version, normalizeCallBack 'set', zkPath, onReady

