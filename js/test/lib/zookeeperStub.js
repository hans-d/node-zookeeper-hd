// This file has been generated from coffee source files

var ApiStub, zookeeperChild2Cb, zookeeperChildCb, zookeeperDataCb, zookeeperMkdirpCb, zookeeperPathCB, zookeeperStatCb, zookeeperVoidCb, zookeeperWatchCb;

exports.Client = ApiStub = (function() {
  function ApiStub(options) {
    this.options = options;
  }

  ApiStub.prototype.close = function() {
    throw 'not implemented';
  };

  ApiStub.prototype.a_create = function(path, data, flags, path_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.mkdirp = function(path, mkdirp_callback) {
    throw 'not implemented';
  };

  ApiStub.prototype.a_exists = function(path, watch, stat_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.a_get = function(path, watch, data_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.a_get_children = function(path, watch, child_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.a_get_children2 = function(path, watch, child2_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.a_set = function(path, data, version, stat_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.a_delete_ = function(path, version, void_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.aw_exists = function(path, watch_cb, stat_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.aw_get = function(path, watch_cb, data_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.aw_get_children = function(path, watch_cb, child_cb) {
    throw 'not implemented';
  };

  ApiStub.prototype.aw_get_children2 = function(path, watch_cb, child2_cb) {
    throw 'not implemented';
  };

  return ApiStub;

})();

zookeeperPathCB = function(rc, error, path) {};

zookeeperStatCb = function(rc, error, stat) {};

zookeeperDataCb = function(rc, error, stat, data) {};

zookeeperChildCb = function(rc, error, children) {};

zookeeperChild2Cb = function(rc, error, children, stat) {};

zookeeperVoidCb = function(rc, error) {};

zookeeperWatchCb = function(type, state, path) {};

zookeeperMkdirpCb = function(error) {};

/*
//@ sourceMappingURL=zookeeperStub.js.map
*/