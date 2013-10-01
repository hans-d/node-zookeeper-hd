// This file has been generated from coffee source files

var DummyLogger, SimpleClient, Zookeeper, normalizeCallBack, path, _;

Zookeeper = require('zookeeper');

path = require('path');

_ = require('underscore');

normalizeCallBack = function(onData) {
  return function(resultCode, error, data1, data2) {
    if (resultCode !== 0) {
      return onData({
        rc: resultCode,
        msg: error
      });
    }
    return onData(null, data1, data2);
  };
};

DummyLogger = (function() {
  function DummyLogger() {}

  DummyLogger.prototype.info = function() {};

  DummyLogger.prototype.debug = function() {};

  return DummyLogger;

})();

module.exports = SimpleClient = (function() {
  function SimpleClient(options) {
    options = options || {};
    this.client = new Zookeeper(options);
    this.log = options.logger || new DummyLogger();
    this.root = options.root || '';
  }

  SimpleClient.prototype.fullPath = function(relativePath) {
    return this.joinPath(this.root, relativePath);
  };

  SimpleClient.prototype.joinPath = function(base, extra) {
    extra = extra || '';
    if (_.isArray(base)) {
      base = path.join.apply(this, _.flatten(base));
    }
    if (_.isArray(extra)) {
      extra = path.join.apply(this, _.flatten(extra));
    }
    return path.join(base, extra);
  };

  SimpleClient.prototype.create = function(zkPath, value, flags, onReady) {
    this.log.info("create " + value + " @ " + path);
    return this.client.a_create(this.fullPath(zkPath), value, flags, normalizeCallBack(onReady));
  };

  SimpleClient.prototype.exists = function(zkPath, watch, onData) {
    this.log.debug("exists @ " + zkPath);
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
    this.log.debug("get @ " + zkPath);
    return this.client.a_get(this.fullPath(zkPath), watch, normalizeCallBack(onData));
  };

  SimpleClient.prototype.getChildren = function(zkPath, watch, onData) {
    this.log.debug("getChildren @ " + zkPath);
    return this.client.a_get_children(this.fullPath(zkPath), watch, normalizeCallBack(onData));
  };

  SimpleClient.prototype.mkdir = function(zkPath, onReady) {
    this.log.info("mkdir {#zkPath}");
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
    this.log.info("set " + value + " (v " + version + ") @ " + zkPath);
    return this.client.a_set(this.fullPath(zkPath), value, version, normalizeCallBack(onReady));
  };

  return SimpleClient;

})();

/*
//@ sourceMappingURL=SimpleClient.js.map
*/