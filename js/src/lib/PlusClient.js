// This file has been generated from coffee source files

var DummyLogger, PlusClient, SimpleClient, async, _;

SimpleClient = require('./SimpleClient');

_ = require('underscore');

async = require('async');

DummyLogger = (function() {
  function DummyLogger() {}

  DummyLogger.prototype.info = function() {};

  DummyLogger.prototype.debug = function() {};

  return DummyLogger;

})();

module.exports = PlusClient = (function() {
  function PlusClient(options) {
    this.client = new SimpleClient(options);
    this.log = options.logger || new DummyLogger();
  }

  PlusClient.prototype.create = function(zkPath, value, options, onReady) {
    if (!onReady) {
      this.log.debug('create: no onReady argument, inserting empty options');
      onReady = options;
      options = {};
    }
    if (!_.isObject(options)) {
      this.log.debug('create: non object options, moving it to options.flags');
      options = {
        flags: options
      };
    }
    options = _.defaults(options, {
      flags: null
    });
    return this.client.create(zkPath, value, options.flags, onReady);
  };

  PlusClient.prototype.exists = function(zkPath, options, onData) {
    if (!onData) {
      this.log.debug('exists: no onData argument, inserting empty options');
      onData = options;
      options = {};
    }
    if (!_.isObject(options)) {
      this.log.debug('exists: non object options, moving it to options.watch');
      options = {
        watch: options
      };
    }
    options = _.defaults(options, {
      watch: null
    });
    return this.client.exists(zkPath, options.watch, onData);
  };

  PlusClient.prototype.get = function(zkPath, options, onData) {
    if (!onData) {
      this.log.debug('get: no onData argument, inserting empty options');
      onData = options;
      options = {};
    }
    if (!_.isObject(options)) {
      this.log.debug('get: non object options, moving it to options.watch');
      options = {
        watch: options
      };
    }
    options = _.defaults(options, {
      watch: null
    });
    return this.client.get(zkPath, options.watch, onData);
  };

  PlusClient.prototype.getChildren = function(zkPath, options, onData) {
    var _this = this;
    if (!onData) {
      this.log.debug('getChildren: no onData argument, inserting empty options');
      onData = options;
      options = {};
    }
    if (!_.isObject(options)) {
      this.log.debug('getChildren: non object options, moving it to options.watch');
      options = {
        watch: options
      };
    }
    options = _.defaults(options, {
      watch: null,
      createPathIfNotExists: false
    });
    return async.waterfall([
      function(asyncReady) {
        if (!options.createPathIfNotExists) {
          return asyncReady();
        }
        return _this.createPathIfNotExists(zkPath, options, asyncReady);
      }, function(asyncReady) {
        return _this.client.getChildren(zkPath, options.watch, asyncReady);
      }
    ], function(err, result) {
      return onData(err, result);
    });
  };

  PlusClient.prototype.mkdir = function(zkPath, options, onReady) {
    if (!onReady) {
      this.log.debug('mkdir: no onReady argument, inserting empty options');
      onReady = options;
      options = {};
    }
    return this.client.mkdir(zkPath, onReady);
  };

  PlusClient.prototype.set = function(zkPath, value, version, options, onReady) {
    if (!onReady) {
      this.log.debug('set: no onReady argument, inserting empty options');
      onReady = options;
      options = {};
    }
    return this.client.set(zkPath, value, version, onReady);
  };

  PlusClient.prototype.createPathIfNotExists = function(zkPath, options, onReady) {
    if (!onReady) {
      this.log.debug('createPathIfNotExist: no onReady argument, inserting empty options');
      onReady = options;
      options = {};
    }
    this.log.info("createPathIfNotExists " + zkPath);
    return this.mkdir(zkPath, options, onReady);
  };

  PlusClient.prototype.createOrUpdate = function(zkPath, value, options, onReady) {
    var _this = this;
    if (!onReady) {
      this.log.debug('createOrUpdate: no onReady argument, inserting empty options');
      onReady = options;
      options = {};
    }
    if (!_.isObject(options)) {
      this.log.debug('createOrUpdate: non object options, moving it to options.flags; onReady -> options.watch, onReady = arguments[4]');
      options = {
        flags: options,
        watch: onReady
      };
      onReady = arguments[4];
    }
    options = _.defaults(options, {
      flags: null,
      watch: null
    });
    this.log.info("#createOrUpdate " + value + " @ " + zkPath);
    return this.exists(zkPath, options, function(err, exists, stat) {
      if (err) {
        return onReady(err);
      }
      if (exists) {
        return _this.set(zkPath, value, stat.version, onReady);
      }
      return _this.create(zkPath, value, options, onReady);
    });
  };

  return PlusClient;

})();

/*
//@ sourceMappingURL=PlusClient.js.map
*/