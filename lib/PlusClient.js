// This file has been generated from coffee source files

var PlusClient, SimpleClient, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

SimpleClient = require('./SimpleClient');

module.exports = PlusClient = (function(_super) {
  __extends(PlusClient, _super);

  function PlusClient() {
    _ref = PlusClient.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  PlusClient.prototype.createOrUpdate = function(zkPath, value, flags, watch, onReady) {
    var _this = this;
    this.log.info("setOrCreate " + value + " @ " + zkPath);
    return this.exists(zkPath, watch, function(err, exists, stat) {
      if (err) {
        return onReady(err);
      }
      if (exists) {
        return _this.set(zkPath, value, stat.version, onReady);
      }
      return _this.create(zkPath, value, flags, onReady);
    });
  };

  PlusClient.prototype.createPathIfNotExist = function(zkPath, onReady) {
    this.log.info("createPathIfNotExists " + zkPath);
    return this.mkdir(zkPath, onReady);
  };

  return PlusClient;

})(SimpleClient);

/*
//@ sourceMappingURL=PlusClient.js.map
*/