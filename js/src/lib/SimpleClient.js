// This file has been generated from coffee source files

var SimpleClient, Zookeeper, normalizeCallBack, _;

Zookeeper = require('zookeeper');

_ = require('underscore');

normalizeCallBack = function(onData) {
  return function(resultCode, error, data1, data2) {
    if (resultCode !== 0) {
      return onData({
        rc: resultCode,
        msg: error
      });
    }
    if (arguments.length <= 3) {
      return onData(null, data1);
    }
    return onData(null, data1, data2);
  };
};

module.exports = SimpleClient = (function() {
  function SimpleClient(options) {
    options = options || {};
    this.client = new Zookeeper(options);
    this.root = options.root || '/';
  }

  SimpleClient.prototype.connect = function(onReady) {
    return this.client.connect(onReady);
  };

  SimpleClient.prototype.fullPath = function(relativePath) {
    return this.joinPath(this.root, relativePath);
  };

  SimpleClient.prototype.joinPath = function(base, extra) {
    var all;
    all = [];
    if (base) {
      all.push(base);
    }
    if (extra) {
      all.push(extra);
    }
    return (_.flatten(all)).join('/').replace('///', '/').replace('//', '/');
  };

  SimpleClient.prototype.create = function(zkPath, value, flags, onReady) {
    return this.client.a_create(this.fullPath(zkPath), value, flags, normalizeCallBack(onReady));
  };

  SimpleClient.prototype.exists = function(zkPath, watch, onData) {
    return this.client.a_exists(this.fullPath(zkPath), watch, function(resultCode, error, stat) {
      if (resultCode === 0) {
        return onData(null, true, stat);
      }
      if (error === 'no node') {
        return onData(null, false);
      }
      return onData({
        msg: error,
        rc: resultCode
      }, false);
    });
  };

  SimpleClient.prototype.get = function(zkPath, watch, onData) {
    return this.client.a_get(this.fullPath(zkPath), watch, normalizeCallBack(onData));
  };

  SimpleClient.prototype.getChildren = function(zkPath, watch, onData) {
    return this.client.a_get_children(this.fullPath(zkPath), watch, normalizeCallBack(onData));
  };

  SimpleClient.prototype.mkdir = function(zkPath, onReady) {
    return this.client.mkdirp(this.fullPath(zkPath), function(err) {
      if (err) {
        return onReady({
          msg: err,
          rc: null
        });
      }
      return onReady();
    });
  };

  SimpleClient.prototype.set = function(zkPath, value, version, onReady) {
    return this.client.a_set(this.fullPath(zkPath), value, version, normalizeCallBack(onReady));
  };

  return SimpleClient;

})();

/*
//@ sourceMappingURL=SimpleClient.js.map
*/