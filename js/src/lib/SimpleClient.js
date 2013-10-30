// This file has been generated from coffee source files

var SimpleClient, Zookeeper, normalizeCallBack, _;

Zookeeper = require('zookeeper');

_ = require('underscore');

/*
  Utility function for normalizing underlying zookeeper callback and providing some
  extra detail

  @param {String} action Name of zookeeper action
  @param {Mixed} path Provided (relative) path for the action
  @param {Function} callback Callback to use

  @return {Function} Normalized callback
  @return {Integer} return.resultCode Zookeeper resultCode
  @return {String} return.error Zookeeper error message
  @return {Mixed} return.data1 Placekeeper for extra provided argument 1
  @return {Mixed} return.data2 Placekeeper for extra provided argument 2
  @return {Object} return.return Provided callback to calling method
  @return {Object} return.return.error Null if no error, otherwise
  @return {Integer} return.return.error.rc Zookeeper resultcode
  @return {String} return.return.error.msg Zookeeper error message
  @return {Mixed} return.return.error.path Path causing the error
  @return {String} return.return.error.action Action causing the error
  @return {Mixed} return.return.data1 Placekeeper for extra provided argument 1
  @return {Mixed} return.return.data2 Placekeeper for extra provided argument 2
*/


normalizeCallBack = function(action, path, callback) {
  return function(resultCode, error, data1, data2) {
    if (resultCode !== 0) {
      return callback({
        rc: resultCode,
        msg: error,
        path: path,
        action: action
      });
    }
    if (arguments.length <= 3) {
      return callback(null, data1);
    }
    return callback(null, data1, data2);
  };
};

/*
  Wraps the [zookeeper](https://github.com/yfinkelstein/node-zookeeper) module to
  normalize function names and callback signatures, and a few extras.

  Method signature are the same as for the underlying zookeeper module.

  - ```a_``` (async) prefix for function names are removed
  - callback will have a single error argument instead of 2: ```{ rc: resultCode, msg: error }```
  - constructor allows for ```root``` option to provide base root for all given paths
  - provided paths are relative to the given root, and can be String or nested String[]
  - ```joinPath``` to generate full path from given components

  TODO: watches
*/


module.exports = SimpleClient = (function() {
  /*
    Constructs SimpleClient, and underlying zookeeper client
  
    Does not yet connect to zookeeper, use #connect for that.
  
    @param [options="{root: '/'}"] Optional option
    @param options.root Root path for all zookeeper operations
  */

  function SimpleClient(options) {
    options = options || {};
    this.client = new Zookeeper(options);
    this.root = options.root || '/';
  }

  /*
    Connects to zookeeper
  
    @param {Function} onReady Callback
    @param {String} onReady.err Error message in case of error
  */


  SimpleClient.prototype.connect = function(onReady) {
    return this.client.connect(onReady);
  };

  /*
    Utility function to get the path relative to the given root
  
    @return {String} Absolute path including root
  */


  SimpleClient.prototype.fullPath = function(relativePath) {
    return this.joinPath(this.root, relativePath);
  };

  /*
    Utility function to join path segments.
  
    Each segment can be a string, an array, or a nested array
  
    @return {String} Full path constructed of given components
  */


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

  /*
    Create an entry at the given path,
  
    The parent of the path must exist, path may not yet exist.
  
    @param {Mixed} zkPath relative path
    @param value
    @param flags
    @param {Function} onReady normalized callBack
    @param {Object} onReady.error In case of error
    @param {Object} onReady.path Created path
  */


  SimpleClient.prototype.create = function(zkPath, value, flags, onReady) {
    return this.client.a_create(this.fullPath(zkPath), value, flags, normalizeCallBack('create', zkPath, onReady));
  };

  /*
    Does given path exist.
  
    Does not provide an error if the path does not exist (as the underlying client does)
  
    @param {Mixed} zkPath relative path
    @param watch Not yet implemented
    @param {Function} onData normalized callBack
    @param {Object} onData.error In case of error
    @param {Boolean} onData.exists True if path exists
    @param {Object} onData.stats ```Stat``` if path exists
  */


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
        rc: resultCode,
        action: 'exists',
        path: zkPath
      }, false);
    });
  };

  /*
    Get data from the given path.
  
    @param {Mixed} zkPath relative path
    @param watch Not yet implemented
    @param {Function} onData normalized callBack
    @param {Object} onData.error In case of error
    @param {Object} onData.stat
    @param {String} onData.data
  */


  SimpleClient.prototype.get = function(zkPath, watch, onData) {
    return this.client.a_get(this.fullPath(zkPath), watch, normalizeCallBack('get', zkPath, onData));
  };

  /*
    Get children from the given path.
  
    @param {Mixed} zkPath relative path
    @param watch Not yet implemented
    @param {Function} onData normalized callBack
    @param {Object} onData.error In case of error
    @param {String[]} onData.children Names are relative to provided path
  */


  SimpleClient.prototype.getChildren = function(zkPath, watch, onData) {
    return this.client.a_get_children(this.fullPath(zkPath), watch, normalizeCallBack('getChildren', zkPath, onData));
  };

  /*
    Creates full path, and any missing parents
  
    Function is client specific, and is not an original zookeeper action.
  
    @param {Mixed} zkPath relative path
    @param {Function} onReady normalized callBack
    @param {Object} onReady.error In case of error
  */


  SimpleClient.prototype.mkdir = function(zkPath, onReady) {
    return this.client.mkdirp(this.fullPath(zkPath), function(err) {
      if (err) {
        return onReady({
          msg: err,
          rc: null,
          action: 'mkdir',
          path: zkPath
        });
      }
      return onReady();
    });
  };

  /*
    Sets entry at given path.
  
    Path must exist, version must be same as current value (or -1).
  
    @param {Mixed} zkPath relative path
    @param {String} value Value to write
    @param version Current version, or -1 (other value will cause error)
    @param {Function} onReady normalized callBack
    @param {Object} onReady.error In case of error
    @param {Object} onReady.stat Updated ```stat```
  */


  SimpleClient.prototype.set = function(zkPath, value, version, onReady) {
    return this.client.a_set(this.fullPath(zkPath), value, version, normalizeCallBack('set', zkPath, onReady));
  };

  return SimpleClient;

})();

/*
//@ sourceMappingURL=SimpleClient.js.map
*/