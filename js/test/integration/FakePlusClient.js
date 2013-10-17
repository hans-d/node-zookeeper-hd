// This file has been generated from coffee source files

var mockery, should, sinon;

should = require('should');

sinon = require('sinon');

mockery = require('mockery');

describe('PlusClient with a FakeZookeeper', function() {
  var PlusClient, client, zk;
  PlusClient = null;
  client = zk = null;
  before(function() {
    mockery.enable({
      useCleanCache: true
    });
    mockery.registerAllowables(['../../src/lib/PlusClient', './SimpleClient', 'path', 'events', 'async', 'underscore']);
    mockery.registerSubstitute('zookeeper', '../../src/lib/FakeZookeeper');
    return PlusClient = require('../../src/lib/PlusClient');
  });
  after(function() {
    mockery.deregisterAll();
    return mockery.disable();
  });
  beforeEach(function() {
    client = new PlusClient();
    return zk = client.client.client;
  });
  afterEach(function() {
    return client = null;
  });
  describe('Test setup', function() {
    it('should have a client (SimpleClient)', function() {
      should.exist(client.client);
      return client.client.constructor.name.should.equal('SimpleClient');
    });
    return it('should have a nested client (FakeZookeeper)', function() {
      should.exist(client.client.client);
      client.client.client.constructor.name.should.equal('FakeZookeeper');
      return client.client.client.should.equal(zk);
    });
  });
  return describe('Zookeeper client actions', function() {
    beforeEach(function(done) {
      return client.create('/foo', 'bar', function(err) {
        should.not.exist(err);
        return done();
      });
    });
    describe('#create', function() {
      beforeEach(function() {
        client = new PlusClient();
        return zk = client.client.client;
      });
      it('can create a node', function(done) {
        return client.create('/foo', 'bar', {
          flags: 1
        }, function(err) {
          should.not.exist(err);
          zk.registry._nodes.should.have.keys('/', '/foo');
          return done();
        });
      });
      it('should contain the correct data', function(done) {
        return client.create('/foo', 'bar', {
          flags: 1
        }, function(err) {
          should.not.exist(err);
          zk.registry._nodes['/foo'].should.include({
            value: 'bar',
            flags: 1
          });
          return done();
        });
      });
      it('can create a node with missing parents', function(done) {
        return client.create('/foo/bar/awesome', 'bar', {
          flags: 1,
          createPathIfNotExists: true
        }, function(err) {
          should.not.exist(err);
          zk.registry._nodes.should.have.keys('/', '/foo', '/foo/bar', '/foo/bar/awesome');
          return done();
        });
      });
      return it('can be retrieved with a get', function(done) {
        return client.create('/foo', 'bar', function(err) {
          should.not.exist(err);
          return client.get('/foo', function(err, stat, value) {
            should.not.exist(err);
            value.should.equal('bar');
            return done();
          });
        });
      });
    });
    describe('#exists', function() {
      it('returns true and stat if exists', function(done) {
        return client.exists('/foo', function(err, exists, stat) {
          should.not.exist(err);
          exists.should.be["true"];
          stat.should.eql({
            version: 1
          });
          return done();
        });
      });
      return it('returns false if not exists', function(done) {
        return client.exists('/foo2', function(err, exists, stat) {
          should.not.exist(err);
          exists.should.be["false"];
          return done();
        });
      });
    });
    describe('#get', function() {
      return it('can retrieve', function(done) {
        return client.get('/foo', function(err, stat, value) {
          should.not.exist(err);
          value.should.equal('bar');
          return done();
        });
      });
    });
    describe('#getChildren', function() {
      beforeEach(function(done) {
        return client.create('/foo/foo', 'foo-result', function(err) {
          should.not.exist(err);
          return client.create('/foo/bar', 'bar-result', function(err) {
            should.not.exist(err);
            return done();
          });
        });
      });
      return it('can retrieve the child values with getChildData', function(done) {
        return client.getChildren('/foo', {
          getChildData: true
        }, function(err, res) {
          should.not.exist(err);
          res.should.eql({
            foo: "foo-result",
            bar: "bar-result"
          });
          return done();
        });
      });
    });
    describe('#mkdir', function() {
      return it('can create a node with all its parents', function(done) {
        return client.mkdir('/some/long/path', function(err) {
          should.not.exist(err);
          return client.exists('/some/long/path', function(err, exists, stat) {
            should.not.exist(err);
            exists.should.be["true"];
            return done();
          });
        });
      });
    });
    describe('#set', function() {
      return it('can update an existing node');
    });
    describe('#createOrUpdate', function() {
      it('can update an existing node');
      return it('can create a new node');
    });
    return describe('#createPathIfNotExists', function() {
      it('can create a path if not exists');
      return it('doen not fail when the path already exists');
    });
  });
});

/*
//@ sourceMappingURL=FakePlusClient.js.map
*/