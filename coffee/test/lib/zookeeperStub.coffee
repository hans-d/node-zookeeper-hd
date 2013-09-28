# Zookeeper client skeleton
# As described on https://github.com/yfinkelstein/node-zookeeper

# use instead of the real zookeeper client to test without zookeeper instance

exports.Client = class ApiStub

  constructor: (options) ->
    @options = options

  close: ( ) ->
    throw 'not implemented'
  a_create: ( path, data, flags, path_cb ) ->
    throw 'not implemented'
  mkdirp: ( path, mkdirp_callback ) ->
    throw 'not implemented'
  a_exists: ( path, watch, stat_cb ) ->
    throw 'not implemented'
  a_get: ( path, watch, data_cb ) ->
    throw 'not implemented'
  a_get_children: ( path, watch, child_cb ) ->
    throw 'not implemented'
  a_get_children2: ( path, watch, child2_cb ) ->
    throw 'not implemented'
  a_set: ( path, data, version, stat_cb ) ->
    throw 'not implemented'
  a_delete_: ( path, version, void_cb ) ->
    throw 'not implemented'
  aw_exists: ( path, watch_cb, stat_cb ) ->
    throw 'not implemented'
  aw_get: ( path, watch_cb, data_cb ) ->
    throw 'not implemented'
  aw_get_children: ( path, watch_cb, child_cb ) ->
    throw 'not implemented'
  aw_get_children2: ( path, watch_cb, child2_cb ) ->
    throw 'not implemented'


zookeeperPathCB = ( rc, error, path ) ->
zookeeperStatCb = ( rc, error, stat ) ->
zookeeperDataCb = ( rc, error, stat, data ) ->
zookeeperChildCb = ( rc, error, children ) ->
zookeeperChild2Cb = ( rc, error, children, stat ) ->
zookeeperVoidCb = ( rc, error ) ->
zookeeperWatchCb = ( type, state, path ) ->
zookeeperMkdirpCb = ( error ) ->
