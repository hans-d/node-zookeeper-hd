Zookeeper = require 'zookeeper'
path = require 'path'
_ = require 'underscore'

normalizeCallBack = (onData) ->
  return (resultCode, error, data1, data2) ->
    return onData(rc: resultCode, msg: error) if resultCode != 0
    onData null, data1, data2

# Used client: 'zookeeper' - https://github.com/yfinkelstein/node-zookeeper
# Normalizes function names and callback signatures

module.exports = class SimpleClient

  constructor: (options) ->
    options = options || {}
    @client = new Zookeeper options
    @root = options.root || ''

  connect: (onReady) ->
    @client.connect onReady

  fullPath: (relativePath) ->
    return @joinPath @root, relativePath

  joinPath: (base, extra) ->
    extra = extra || ''
    base = path.join.apply @, _.flatten base if _.isArray base
    extra = path.join.apply @, _.flatten extra if _.isArray extra
    return path.join base, extra

  create: (zkPath, value, flags, onReady) ->
    @client.a_create @fullPath(zkPath), value, flags, normalizeCallBack onReady

  exists: (zkPath, watch, onData) ->
    @client.a_exists @fullPath(zkPath), watch, (resultCode, error, stat) ->
      return onData(null, true, stat) if resultCode == 0
      return onData(null, false) if error == 'no node'
      onData msg: error, rc: resultCode, false

  get: (zkPath, watch, onData) ->
    @client.a_get @fullPath(zkPath), watch, normalizeCallBack onData

  getChildren: (zkPath, watch, onData) ->
    @client.a_get_children @fullPath(zkPath), watch, normalizeCallBack onData

  mkdir: (zkPath, onReady) ->
    # NB: callback is different!
    @client.mkdirp @fullPath(zkPath), (err) ->
      return onReady msg: err, rc: null if err
      onReady()

  set: (zkPath, value, version, onReady) ->
    @client.a_set @fullPath(zkPath), value, version, normalizeCallBack onReady

