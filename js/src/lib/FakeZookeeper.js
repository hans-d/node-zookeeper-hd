// This file has been generated from coffee source files

var FakeZookeeper, SimpleRegistry, ZKCONST, async, events, path, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('underscore');

path = require('path');

async = require('async');

events = require('events');

ZKCONST = {
  ZOK: 0,
  ZSYSTEMERROR: -1,
  ZRUNTIMEINCONSISTENCY: -2,
  ZDATAINCONSISTENCY: -3,
  ZCONNECTIONLOSS: -4,
  ZMARSHALLINGERROR: -5,
  ZUNIMPLEMENTED: -6,
  ZOPERATIONTIMEOUT: -7,
  ZBADARGUMENTS: -8,
  ZINVALIDSTATE: -9,
  ZAPIERROR: -100,
  ZNONODE: -101,
  ZNOAUTH: -102,
  ZBADVERSION: -103,
  ZNOCHILDRENFOREPHEMERALS: -108,
  ZNODEEXISTS: -110,
  ZNOTEMPTY: -111,
  ZSESSIONEXPIRED: -112,
  ZINVALIDCALLBACK: -113,
  ZINVALIDACL: -114,
  ZAUTHFAILED: -115,
  ZCLOSING: -116,
  ZNOTHING: -117,
  ZSESSIONMOVED: -118
};

SimpleRegistry = (function(_super) {
  __extends(SimpleRegistry, _super);

  function SimpleRegistry() {
    this._nodes = {};
    this.add('/');
  }

  SimpleRegistry.prototype.add = function(p, options) {
    var node, parent;
    p = this.normalize(p);
    parent = p === '/' ? '/' : this.parentname(p);
    options = options || {};
    node = _.extend(_.defaults(options, {
      value: options.value || null,
      version: options.version || 1,
      flags: options.flags || 0
    }), {
      path: p,
      parent: parent,
      childs: {}
    });
    this._nodes[p] = node;
    this.emit('created'.p);
    if (p === '/') {
      return;
    }
    this._nodes[this.parentname(p)].childs[this.basename(p)] = node.path;
    return this.emit('child', this.parentname(p));
  };

  SimpleRegistry.prototype.read = function(p) {
    p = this.normalize(p);
    return this._nodes[p];
  };

  SimpleRegistry.prototype.update = function(p, options) {
    var changed, key, value;
    p = this.normalize(p);
    changed = false;
    for (key in options) {
      value = options[key];
      if (!(key === 'value' || key === 'flags')) {
        continue;
      }
      changed = true;
      this._nodes[p][key] = value;
    }
    if (changed) {
      this._nodes[p].version = this._nodes[p].version + 1;
    }
    return this.emit('changed', p);
  };

  SimpleRegistry.prototype["delete"] = function(p) {
    p = this.normalize(p);
    delete this._nodes[p];
    this.emit('deleted', p);
    if (p !== '/') {
      delete this._nodes[this.parentname(p)].childs[this.basename(p)];
      return this.emit('child', this.parentname(p));
    }
  };

  SimpleRegistry.prototype.exists = function(p) {
    p = this.normalize(p);
    return p in this._nodes;
  };

  SimpleRegistry.prototype.exists_parent = function(p) {
    p = this.normalize(p);
    return this.parentname(p) in this._nodes;
  };

  SimpleRegistry.prototype.normalize = function(p) {
    return path.normalize(p);
  };

  SimpleRegistry.prototype.parentname = function(p) {
    return path.dirname(p);
  };

  SimpleRegistry.prototype.basename = function(p) {
    return path.basename(p);
  };

  return SimpleRegistry;

})(events.EventEmitter);

module.exports = FakeZookeeper = (function(_super) {
  __extends(FakeZookeeper, _super);

  function FakeZookeeper(options) {
    this.options = options;
    this.registry = new SimpleRegistry();
  }

  FakeZookeeper.prototype.close = function() {};

  FakeZookeeper.prototype.connect = function(cb) {
    return cb();
  };

  FakeZookeeper.prototype._stat = function(node) {
    return {
      version: node.version
    };
  };

  FakeZookeeper.prototype._match_version = function(version, node) {
    return version === -1 || version === node.version;
  };

  FakeZookeeper.prototype.watch_exists = function(p, watcher) {};

  FakeZookeeper.prototype.watch_data = function(p, watcher) {};

  FakeZookeeper.prototype.watch_children = function(p, watcher) {};

  FakeZookeeper.prototype.a_create = function(p, data, flags, cb) {
    if (this.registry.exists(p)) {
      return cb(ZKCONST.ZNODEEXISTS, "node exists");
    }
    if (!this.registry.exists_parent(p)) {
      return cb(ZKCONST.ZNONODE, "no node");
    }
    this.registry.add(p, {
      value: data,
      flags: flags
    });
    return cb(ZKCONST.ZOK, null, p);
  };

  FakeZookeeper.prototype.a_delete = function(p, version, cb) {
    var node;
    if (!this.registry.exists(p)) {
      return cb(ZKCONST.ZNONODE, "no node");
    }
    node = this.registry.read(p);
    if (_.keys(node.childs).length !== 0) {
      return cb(ZKCONST.ZNOTEMPTY, "not empty");
    }
    if (!this._match_version(version, node)) {
      return cb(ZKCONST.ZBADVERSION, "bad version");
    }
    this.registry["delete"](p);
    return cb(ZKCONST.ZOK);
  };

  FakeZookeeper.prototype.a_exists = function(p, watch, cb) {
    return this.aw_exists(p, (watch ? true : false), cb);
  };

  FakeZookeeper.prototype.aw_exists = function(p, watch_cb, cb) {
    if (!this.registry.exists(p)) {
      return cb(ZKCONST.ZNONODE, "no node", null);
    }
    if (watch_cb) {
      this.watch_exists(p, watch_cb);
    }
    return cb(ZKCONST.ZOK, null, this._stat(this.registry.read(p)));
  };

  FakeZookeeper.prototype.mkdirp = function(p, cb) {
    var dirs,
      _this = this;
    dirs = p.split('/').slice(1);
    dirs.forEach(function(dir, i) {
      var subpath;
      subpath = '/' + dirs.slice(0, i).join('/') + '/' + dir;
      subpath = path.normalize(subpath);
      if (!_this.registry.exists(subpath)) {
        return _this.registry.add(subpath, {
          data: 'created by zk-mkdir-p'
        });
      }
    });
    return cb(null, true);
  };

  FakeZookeeper.prototype.a_get = function(p, watch, cb) {
    return this.aw_get(p, (watch ? true : false), cb);
  };

  FakeZookeeper.prototype.aw_get = function(p, watch_cb, cb) {
    var node;
    if (!this.registry.exists(p)) {
      return cb(ZKCONST.ZNONODE, "no node", null);
    }
    node = this.registry.read(p);
    if (watch_cb) {
      this.watch_data(p, watch_cb);
    }
    return cb(ZKCONST.ZOK, null, this._stat(node), node.value);
  };

  FakeZookeeper.prototype.a_get_children = function(p, watch, cb) {
    return this.aw_get_children(p, (watch ? true : false), cb);
  };

  FakeZookeeper.prototype.aw_get_children = function(p, watch_cb, cb) {
    var node;
    if (!this.registry.exists(p)) {
      return cb(ZKCONST.ZNONODE, "no node", null);
    }
    node = this.registry.read(p);
    if (watch_cb) {
      this.watch_children(p, watch_cb);
    }
    return cb(ZKCONST.ZOK, null, _.keys(node.childs));
  };

  FakeZookeeper.prototype.a_get_children2 = function(p, watch, cb) {
    return this.aw_get_children2(p, (watch ? true : false), cb);
  };

  FakeZookeeper.prototype.aw_get_children2 = function(p, watch_cb, cb) {
    var node;
    if (!this.registry.exists(p)) {
      return cb(ZKCONST.ZNONODE, "no node", null);
    }
    node = this.registry.read(p);
    if (watch_cb) {
      this.watch_children(p, watch_cb);
    }
    return cb(ZKCONST.ZOK, null, _.keys(node.childs), this._stat(node));
  };

  FakeZookeeper.prototype.a_set = function(p, data, version, cb) {
    var node;
    if (!this.registry.exists(p)) {
      return cb(ZKCONST.ZNONODE, "no node", null);
    }
    node = this.registry.read(p);
    if (!this._match_version(version, node)) {
      return cb(ZKCONST.ZBADVERSION, "bad version");
    }
    this.registry.update(p, {
      value: data
    });
    return cb(ZKCONST.ZOK, null, this._stat(node));
  };

  return FakeZookeeper;

})(events.EventEmitter);

module.exports.ZKCONST = ZKCONST;

/*
//@ sourceMappingURL=FakeZookeeper.js.map
*/