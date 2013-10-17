_ = require 'underscore'
path = require 'path'
async = require 'async'
events = require 'events'

ZKCONST = {
# API Responses:
  ZOK                        :  0
  ZSYSTEMERROR               :  -1
  ZRUNTIMEINCONSISTENCY      :  -2
  ZDATAINCONSISTENCY         :  -3
  ZCONNECTIONLOSS            :  -4
  ZMARSHALLINGERROR          :  -5
  ZUNIMPLEMENTED             :  -6
  ZOPERATIONTIMEOUT          :  -7
  ZBADARGUMENTS              :  -8
  ZINVALIDSTATE              :  -9
  ZAPIERROR                  :  -100
  ZNONODE                    :  -101
  ZNOAUTH                    :  -102
  ZBADVERSION                :  -103
  ZNOCHILDRENFOREPHEMERALS   :  -108
  ZNODEEXISTS                :  -110
  ZNOTEMPTY                  :  -111
  ZSESSIONEXPIRED            :  -112
  ZINVALIDCALLBACK           :  -113
  ZINVALIDACL                :  -114
  ZAUTHFAILED                :  -115
  ZCLOSING                   :  -116
  ZNOTHING                   :  -117
  ZSESSIONMOVED              :  -118
}

class SimpleRegistry extends events.EventEmitter

  constructor: ->
    @_nodes = {};
    @add '/'

  add: (p, options) ->
    p = @normalize p

    parent = if p == '/' then '/' else @parentname p

    options = options || {};
    node = _.extend(_.defaults(options,
      value: options.value || null
      version: options.version || 1
      flags: options.flags || 0
    ),
      path: p
      parent: parent
      childs: {}
    )

    @_nodes[p] = node
    @emit 'created'. p

    return if p == '/'

    @_nodes[@parentname p].childs[@basename p] = node.path
    @emit 'child', @parentname p


  read: (p) ->
    p = @normalize p
    @_nodes[p]

  update: (p, options) ->
    p = @normalize p

    changed = false
    for key, value of  options when key in ['value', 'flags']
      changed = true
      @_nodes[p][key] = value

    @_nodes[p].version = @_nodes[p].version + 1 if changed
    @emit 'changed', p


  delete: (p) ->
    p = @normalize p

    delete @_nodes[p]
    @emit 'deleted', p

    if p != '/'
      delete @_nodes[@parentname p].childs[@basename p]
      @emit 'child', @parentname p


  exists: (p) ->
    p = @normalize p
    return p of @_nodes


  exists_parent: (p) ->
    p = @normalize p
    return @parentname(p) of @_nodes


  normalize: (p) -> path.normalize p
  parentname: (p) -> path.dirname p
  basename: (p) -> path.basename p



module.exports = class FakeZookeeper extends events.EventEmitter

  # http://anismiles.wordpress.com/2010/06/13/zookeeper-%E2%80%93-primer-contd/

  constructor: (options) ->
    @options = options
    @registry = new SimpleRegistry()

  close: ->
    # throw 'not implemented'

  _stat: ( node ) ->
#    o->Set(String::NewSymbol("czxid"), Number::New (stat->czxid), ReadOnly);
#    o->Set(String::NewSymbol("mzxid"), Number::New (stat->mzxid), ReadOnly);
#    o->Set(String::NewSymbol("pzxid"), Number::New (stat->pzxid), ReadOnly);
#    o->Set(String::NewSymbol("dataLength"), Integer::New (statry->dataLength), ReadOnly);
#    o->Set(String::NewSymbol("numChildren"), Integer::New (stat->numChildren), ReadOnly);
#    o->Set(String::NewSymbol("version"), Integer::New (stat->version), ReadOnly);
#    o->Set(String::NewSymbol("cversion"), Integer::New (stat->cversion), ReadOnly);
#    o->Set(String::NewSymbol("aversion"), Integer::New (stat->aversion), ReadOnly);
#    o->Set(String::NewSymbol("ctime"), NODE_UNIXTIME_V8(stat->ctime/1000.), ReadOnly);
#    o->Set(String::NewSymbol("mtime"), NODE_UNIXTIME_V8(stat->mtime/1000.), ReadOnly);
#    o->Set(String::NewSymbol("ephemeralOwner"), idAsString(stat->ephemeralOwner), ReadOnly);
#    o->Set(String::NewSymbol("createdInThisSession"), Boolean::New(myid.client_id == stat->ephemeralOwner), ReadOnly);

    return {
      version: node.version
    }

  _match_version: (version, node) ->
    return version == -1 || version == node.version

  watch_exists: (p, watcher ) ->
    # not implemented yet

  watch_data: (p, watcher ) ->
    # not implemented yet

  watch_children: (p, watcher ) ->
    # not implemented yet

  a_create: ( p, data, flags, cb ) ->
    return cb ZKCONST.ZNODEEXISTS, "node exists" if @registry.exists p
    return cb ZKCONST.ZNONODE, "no node" if !@registry.exists_parent p

    @registry.add p,
      value: data
      flags: flags

    return cb ZKCONST.ZOK, null, p


  a_delete: ( p, version, cb ) ->
    return cb ZKCONST.ZNONODE, "no node" if !@registry.exists p

    node = @registry.read p
    return cb ZKCONST.ZNOTEMPTY, "not empty" if _.keys(node.childs).length != 0
    return cb ZKCONST.ZBADVERSION, "bad version" if !@_match_version version, node

    @registry.delete p
    cb ZKCONST.ZOK


  a_exists: ( p, watch, cb ) ->
    @aw_exists p, (if watch then true else false), cb

  aw_exists: ( p, watch_cb, cb ) ->
    return cb ZKCONST.ZNONODE, "no node", null if !@registry.exists p

    @watch_exists p, watch_cb if watch_cb
    return cb ZKCONST.ZOK, null, @_stat(@registry.read(p))


  mkdirp: ( p, cb ) ->
    # derived from: https://github.com/yfinkelstein/node-zookeeper/blob/master/lib/zookeeper.js #mkdirp
    dirs = p.split('/').slice(1)

    dirs.forEach (dir, i) =>
      subpath = '/' + dirs.slice(0, i).join('/') + '/' + dir
      subpath = path.normalize subpath
      @registry.add subpath, data: 'created by zk-mkdir-p' if !@registry.exists subpath

    return cb null, true


  a_get: ( p, watch, cb ) ->
    @aw_get p, (if watch then true else false), cb

  aw_get: ( p, watch_cb, cb ) ->
    return cb ZKCONST.ZNONODE, "no node", null if !@registry.exists p

    node = @registry.read p

    @watch_data p, watch_cb if watch_cb
    return cb ZKCONST.ZOK, null, @_stat(node), node.value


  a_get_children: ( p, watch, cb ) ->
    @aw_get_children p, (if watch then true else false), cb


  aw_get_children: ( p, watch_cb, cb ) ->
    return cb ZKCONST.ZNONODE, "no node", null if !@registry.exists p

    node = @registry.read p
    @watch_children p, watch_cb if watch_cb
    return cb ZKCONST.ZOK, null, _.keys(node.childs)


  a_get_children2: ( p, watch, cb ) ->
    @aw_get_children2 p, (if watch then true else false), cb


  aw_get_children2: ( p, watch_cb, cb ) ->
    return cb ZKCONST.ZNONODE, "no node", null if !@registry.exists p

    node = @registry.read p
    @watch_children p, watch_cb if watch_cb
    return cb ZKCONST.ZOK, null, _.keys(node.childs), @_stat(node)


  a_set: ( p, data, version, cb ) ->
    return cb ZKCONST.ZNONODE, "no node", null if !@registry.exists p

    node = @registry.read p
    return cb ZKCONST.ZBADVERSION, "bad version" if !@_match_version version, node

    @registry.update p, value: data
    return cb ZKCONST.ZOK, null, @_stat(node)

module.exports.ZKCONST = ZKCONST