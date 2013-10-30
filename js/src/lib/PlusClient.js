// This file has been generated from coffee source files

var PlusClient, SimpleClient, async, path, _;

path = require('path');

_ = require('underscore');

async = require('async');

SimpleClient = require('..').SimpleClient;

/*
  Wraps the SimpleClient to provide enhanced zookeeper client

  - more flexible method signatures, eg watch not required parameter
  - more functionality for action with options, eg ```createPathIfNotExists```
  - more actions, eg ```createOrUpdate```
*/


module.exports = PlusClient = (function() {
  /*
    Constructs PlusClient and underlying SimpleClient.
  
    Does not yet connect to zookeeper, use #connect for that.
  
    @param [options="{root: '/'}"] Optional option
    @param options.root Root path for all zookeeper operations
  */

  function PlusClient(options) {
    this.client = new SimpleClient(options);
  }

  /*
    Connect to Zookeeper
  
    @param {Function} onReady Callback
    @param {String} onReady.err Error message in case of error
  */


  PlusClient.prototype.connect = function(onReady) {
    return this.client.connect(onReady);
  };

  /*
    Create an entry at the given path,
  
    Path may not yet exist.
    If parent path does not yet exist, it will result in an error unless
  ```createPathIfNotExists``` is provided.
  
    @param {Mixed} zkPath relative path
    @param value
    @param {Object} [options="{flags: null, createPathIfNotExists: false}"]
    @param options.flags
    @param {Boolean} options.createPathIfNotExists
    @param {Function} onReady Callback
    @param {Object} onReady.error In case of error
    @param {Object} onReady.path Created path
  */


  PlusClient.prototype.create = function(zkPath, value, options, onReady) {
    var _this = this;
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
      flags: null,
      createPathIfNotExists: false
    });
    return async.waterfall([
      function(asyncReady) {
        if (!options.createPathIfNotExists) {
          return asyncReady();
        }
        return _this.createPathIfNotExists(path.dirname(zkPath), options, asyncReady);
      }, function(asyncReady) {
        return _this.client.create(zkPath, value, options.flags, asyncReady);
      }
    ], function(err, path) {
      return onReady(err, path);
    });
  };

  /*
    Does given path exist.
  
    @param {Mixed} zkPath relative path
    @param {Object} [options="{watch: null}"]
    @param options.watch
    @param {Function} onData CallBack
    @param {Object} onData.error In case of error
    @param {Boolean} onData.exists True if path exists
    @param {Object} onData.stats ```Stat``` if path exists
  */


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

  /*
    Get data from the given path.
  
    @param {Mixed} zkPath relative path
    @param {Object} [options="{watch: null, createPathIfNotExists: false}"]
    @param options.watch
    @param {Boolean} options.createPathIfNotExists
    @param {Function} onData CallBack
    @param {Object} onData.error In case of error
    @param {Object} onData.stat
    @param {String} onData.data
  
    TODO: return stat & data as one if callback signature has 2 arguments
  */


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

  /*
    Get children from the given path, if ```getChildData``` is provided including their data
  
    @param {Mixed} zkPath relative path
    @param {Object} [options="{watch: null, createPathIfNotExists: false, getChildData: false, levels: 1}"]
    @param options.watch
    @param {Boolean} options.createPathIfNotExists
    @param {Boolean} options.getChildData
    @param {Boolean} options.levels
    @param {Function} onData CallBack
    @param {Object} onData.error In case of error
    @param {String[]} onData.children Names are relative to provided path
  */


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

  /*
    Utility function to join path segments.
  
    Each segment can be a string, an array, or a nested array
  
    @return {String} Full path constructed of given components
  */


  PlusClient.prototype.joinPath = function(base, extra) {
    return this.client.joinPath(base, extra);
  };

  /*
    Creates full path, and any missing parents
  
    @param {Mixed} zkPath relative path
    @param {Object} [options="{}"]
    @param {Function} onReady CallBack
    @param {Object} onReady.error In case of error
  */


  PlusClient.prototype.mkdir = function(zkPath, options, onReady) {
    if (!onReady) {
      onReady = options;
      options = {};
    }
    return this.client.mkdir(zkPath, onReady);
  };

  /*
    Sets entry at given path.
  
    Path must exist, version must be same as current value (or -1).
  
    @param {Mixed} zkPath relative path
    @param {String} value Value to write
    @param version Current version, or -1 (other value will cause error)
    @param {Object} [options="{watch: null, createPathIfNotExists: false}"]
    @param {Boolean} options.createPathIfNotExists
    @param {Function} onReady CallBack
    @param {Object} onReady.error In case of error
    @param {Object} onReady.stat Updated ```stat```
  */


  PlusClient.prototype.set = function(zkPath, value, version, options, onReady) {
    var _this = this;
    if (!onReady) {
      onReady = options;
      options = {};
    }
    options = _.defaults(options, {
      createPathIfNotExists: false
    });
    return async.waterfall([
      function(asyncReady) {
        if (!options.createPathIfNotExists) {
          return asyncReady();
        }
        return _this.createPathIfNotExists(zkPath, options, asyncReady);
      }, function(asyncReady) {
        return _this.client.set(zkPath, value, version, asyncReady);
      }
    ], function(err, stat) {
      return onReady(err, stat);
    });
  };

  /*
    Explicit named method of why would want to use #mkdir
  */


  PlusClient.prototype.createPathIfNotExists = function(zkPath, options, onReady) {
    if (!onReady) {
      onReady = options;
      options = {};
    }
    return this.mkdir(zkPath, options, onReady);
  };

  /*
    create (set) or update a value at given path
  
    @param {Mixed} zkPath relative path
    @param {String} value Value to write
    @param {Object} [options="{}"] Will use defaults of #set, #create, #exists
    @param {Function} onReady CallBack
    @param {Object} onReady.error In case of error
  */


  PlusClient.prototype.createOrUpdate = function(zkPath, value, options, onReady) {
    var _this = this;
    if (!onReady) {
      onReady = options;
      options = {};
    }
    options = _.defaults(options, {});
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