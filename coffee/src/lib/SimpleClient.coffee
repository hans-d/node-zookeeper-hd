Zookeeper = require 'zookeeper'
path = require 'path'
_ = require 'underscore'

normalizeCallBack = (onData) ->
  return (resultCode, error, data1, data2) ->
    return onData(error) if resultCode != 0
    onData null, data1, data2


class DummyLogger
  info: ->
  debug: ->

# Used client: 'zookeeper' - https://github.com/yfinkelstein/node-zookeeper
# Normalizes function names and callback signatures

module.exports = class SimpleClient

  constructor: (options) ->
    options = options || {}
    @client = new Zookeeper options
    @log = options.logger || new DummyLogger()
    @root = options.root || ''

  fullPath: (relativePath) ->
    return @joinPath @root, relativePath

  joinPath: (base, extra) ->
    extra = extra || ''
    base = path.join.apply @, base if _.isArray base
    extra = path.join.apply @, extra if _.isArray extra
    return path.join base, extra

  create: (zkPath, value, flags, onReady) ->
    @log.info "create #{value} @ #{path}"
    @client.a_create @fullPath(zkPath), value, flags, normalizeCallBack onReady

  exists: (zkPath, watch, onData) ->
    @log.debug "exists @ #{zkPath}"
    @client.a_exists @fullPath(zkPath), watch, (resultCode, error, stat) ->
      return onData(null, true, stat) if resultCode == 0
      return onData(null, false) if error == 'no node'
      onData error, false

  get: (zkPath, watch, onData) ->
    @log.debug "get @ #{zkPath}"
    @client.a_get @fullPath(zkPath), watch, normalizeCallBack onData

  getChildren: (zkPath, watch, onData) ->
    @log.debug "getChildren @ #{zkPath}"
    @client.a_get_children @fullPath(zkPath), watch, normalizeCallBack onData

  mkdir: (zkPath, onReady) ->
    # NB: callback is different!
    @log.info "mkdir {#zkPath}"
    @client.mkdirp @fullPath(zkPath), onReady

  set: (zkPath, value, version, onReady) ->
    @log.info "set #{value} (v #{version}) @ #{zkPath}"
    @client.a_set @fullPath(zkPath), value, version, normalizeCallBack onReady

