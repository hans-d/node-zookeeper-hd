// This file has been generated from coffee source files

var PlusClient, SimpleClient, async, _;

SimpleClient = require('./SimpleClient');

_ = require('underscore');

async = require('async');

module.exports = PlusClient = (function() {
  function PlusClient(options) {
    this.client = new SimpleClient(options);
  }

  PlusClient.prototype.connect = function(onReady) {
    return this.client.connect(onReady);
  };

  PlusClient.prototype.create = function(zkPath, value, options, onReady) {
    if (!onReady) {
      onReady = options;
      options = {};
    }
    if (!_.isObject(options)) {
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
      onData = options;
      options = {};
    }
    if (!_.isObject(options)) {
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
    var _this = this;
    if (!onData) {
      onData = options;
      options = {};
    }
    if (!_.isObject(options)) {
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
        return _this.client.get(zkPath, options.watch, asyncReady);
      }
    ], function(err, stat, data) {
      return onData(err, stat, data);
    });
  };

  PlusClient.prototype.getChildren = function(zkPath, options, onData) {
    var _this = this;
    if (!onData) {
      onData = options;
      options = {};
    }
    if (!_.isObject(options)) {
      options = {
        watch: options
      };
    }
    options = _.defaults(options, {
      watch: null,
      createPathIfNotExists: false,
      getChildData: false,
      levels: 1
    });
    return async.waterfall([
      function(asyncReady) {
        if (!options.createPathIfNotExists) {
          return asyncReady();
        }
        return _this.createPathIfNotExists(zkPath, options, asyncReady);
      }, function(asyncReady) {
        return _this.client.getChildren(zkPath, options.watch, asyncReady);
      }, function(children, asyncReady) {
        var childData, nestedOptions;
        if (options.levels === 1) {
          return asyncReady(null, children);
        }
        nestedOptions = _.extend({
          levels: options.levels - 1
        }, _.omit(options, 'levels'));
        childData = {};
        return async.each(children, function(child, asyncChildReady) {
          return _this.getChildren(_this.joinPath(zkPath, child), nestedOptions, function(err, res) {
            if (err) {
              return asyncChildReady(err);
            }
            childData[child] = res;
            return asyncChildReady(null);
          });
        }, function(err) {
          return asyncReady(err, childData);
        });
      }, function(children, asyncReady) {
        var childData;
        if (!(options.getChildData && options.levels === 1)) {
          return asyncReady(null, children);
        }
        childData = {};
        return async.each(children, function(child, asyncChildReady) {
          return _this.get(_this.joinPath(zkPath, child), options, function(err, stat, result) {
            if (err) {
              return asyncChildReady(err);
            }
            childData[child] = result;
            return asyncChildReady();
          });
        }, function(err) {
          return asyncReady(err, childData);
        });
      }
    ], function(err, result) {
      return onData(err, result);
    });
  };

  PlusClient.prototype.joinPath = function(base, extra) {
    return this.client.joinPath(base, extra);
  };

  PlusClient.prototype.mkdir = function(zkPath, options, onReady) {
    if (!onReady) {
      onReady = options;
      options = {};
    }
    return this.client.mkdir(zkPath, onReady);
  };

  PlusClient.prototype.set = function(zkPath, value, version, options, onReady) {
    if (!onReady) {
      onReady = options;
      options = {};
    }
    return this.client.set(zkPath, value, version, onReady);
  };

  PlusClient.prototype.createPathIfNotExists = function(zkPath, options, onReady) {
    if (!onReady) {
      onReady = options;
      options = {};
    }
    return this.mkdir(zkPath, options, onReady);
  };

  PlusClient.prototype.createPathIfNotExist = function(zkPath, options, onReady) {
    return createPathIfNotExists(zkPath, options, onReady);
  };

  PlusClient.prototype.createOrUpdate = function(zkPath, value, options, onReady) {
    var _this = this;
    if (!onReady) {
      onReady = options;
      options = {};
    }
    if (!_.isObject(options)) {
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