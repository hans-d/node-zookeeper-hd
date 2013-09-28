// This file has been generated from coffee source files

var mockery, should, sinon, zookeeperStub;

should = require('should');

mockery = require('mockery');

sinon = require('sinon');

zookeeperStub = require('../lib/zookeeperStub');

describe('SimpleClient Class', function() {
  var SimpleClient, clientWithRoot, clientWithoutRoot, stub;
  SimpleClient = null;
  clientWithoutRoot = clientWithRoot = stub = null;
  before(function() {
    mockery.enable({
      useCleanCache: true
    });
    mockery.registerAllowable('../../src/lib/SimpleClient');
    mockery.registerAllowables(['path']);
    mockery.registerMock('zookeeper', zookeeperStub.Client);
    return SimpleClient = require('../../src/lib/SimpleClient');
  });
  after(function() {
    mockery.deregisterAll();
    return mockery.disable();
  });
  afterEach(function() {
    return clientWithoutRoot = clientWithRoot = stub = null;
  });
  describe('new SimpleClient', function() {
    it('can be created', function() {
      var client;
      client = new SimpleClient();
      client.should.exist;
      return client.root.should.equal('');
    });
    it('has a zookeeper client', function() {
      var client;
      client = new SimpleClient();
      client.client.should.be["instanceof"](zookeeperStub.Client);
      return client.root.should.equal('');
    });
    return it('can have a root', function() {
      var client;
      client = new SimpleClient({
        root: '/some/Root'
      });
      client.client.should.be["instanceof"](zookeeperStub.Client);
      return client.root.should.equal('/some/Root');
    });
  });
  describe('#fullPath', function() {
    beforeEach(function() {
      clientWithoutRoot = new SimpleClient();
      return clientWithRoot = new SimpleClient({
        root: '/some/Root'
      });
    });
    afterEach(function() {
      clientWithoutRoot = null;
      return clientWithRoot = null;
    });
    it('returns the same path witout a root', function() {
      return clientWithoutRoot.fullPath('/somePath').should.equal('/somePath');
    });
    it('returns a path with root when a root is present', function() {
      return clientWithRoot.fullPath('/somePath').should.equal('/some/Root/somePath');
    });
    it('returns 1 slash between root and path when path has no leading slash', function() {
      return clientWithRoot.fullPath('somePath').should.equal('/some/Root/somePath');
    });
    return it('return the exact path if no root and path is without leading slash', function() {
      return clientWithoutRoot.fullPath('somePath').should.equal('somePath');
    });
  });
  describe('#create', function() {
    beforeEach(function() {
      clientWithoutRoot = new SimpleClient();
      clientWithRoot = new SimpleClient({
        root: '/some/Root'
      });
      return stub = clientWithoutRoot.client.a_create = sinon.stub();
    });
    afterEach(function() {
      return clientWithoutRoot = clientWithRoot = stub = null;
    });
    it('calls a_create with full path', function(done) {
      var mock;
      mock = sinon.mock(clientWithRoot.client);
      mock.expects('a_create').once().withArgs('/some/Root/foo', 'bar', 1).yields(null);
      return clientWithRoot.create('/foo', 'bar', 1, function() {
        mock.verify();
        return done();
      });
    });
    it('gives normalized result callback on ok', function(done) {
      stub.yields(0, 'foo-error', 'foo-result');
      return clientWithoutRoot.create('/foo', 'bar', 1, function(err, res) {
        should.not.exist(err);
        res.should.equal('foo-result');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    return it('gives normalized error callback on error', function(done) {
      stub.yields(1, 'foo-error', 'foo-result');
      return clientWithoutRoot.create('/foo', 'bar', 1, function(err, res) {
        err.should.equal('foo-error');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
  });
  describe('#exists', function() {
    beforeEach(function() {
      clientWithoutRoot = new SimpleClient();
      clientWithRoot = new SimpleClient({
        root: '/some/Root'
      });
      return stub = clientWithoutRoot.client.a_exists = sinon.stub();
    });
    afterEach(function() {
      return clientWithoutRoot = clientWithRoot = stub = null;
    });
    it('calls a_exists with full path', function(done) {
      var mock;
      mock = sinon.mock(clientWithRoot.client);
      mock.expects('a_exists').once().withArgs('/some/Root/foo', 1).yields(null);
      return clientWithRoot.exists('/foo', 1, function() {
        mock.verify();
        return done();
      });
    });
    it('gives normalized result callback on ok', function(done) {
      stub.yields(0, 'foo-error', 'foo-result');
      return clientWithoutRoot.exists('/foo', 1, function(err, exists, res) {
        should.not.exist(err);
        exists.should.equal(true);
        res.should.equal('foo-result');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    it('gives normalized error callback on error', function(done) {
      stub.yields(1, 'foo-error', 'foo-result');
      return clientWithoutRoot.exists('/foo', 1, function(err, exists, res) {
        err.should.equal('foo-error');
        exists.should.equal(false);
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    return it('gives normalized result callback on "no node" error', function(done) {
      stub.yields(1, 'no node', 'foo-result');
      return clientWithoutRoot.exists('/foo', 1, function(err, exists, res) {
        should.not.exist(err);
        exists.should.equal(false);
        should.not.exist(res);
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
  });
  describe('#get', function() {
    beforeEach(function() {
      clientWithoutRoot = new SimpleClient();
      clientWithRoot = new SimpleClient({
        root: '/some/Root'
      });
      return stub = clientWithoutRoot.client.a_get = sinon.stub();
    });
    afterEach(function() {
      return clientWithoutRoot = clientWithRoot = stub = null;
    });
    it('calls a_get with full path', function(done) {
      var mock;
      mock = sinon.mock(clientWithRoot.client);
      mock.expects('a_get').once().withArgs('/some/Root/foo', 1).yields(null);
      return clientWithRoot.get('/foo', 1, function() {
        mock.verify();
        return done();
      });
    });
    it('gives normalized result callback on ok', function(done) {
      stub.yields(0, 'foo-error', 'foo-result');
      return clientWithoutRoot.get('/foo', 1, function(err, res) {
        should.not.exist(err);
        res.should.equal('foo-result');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    return it('gives normalized error callback on error', function(done) {
      stub.yields(1, 'foo-error', 'foo-result');
      return clientWithoutRoot.get('/foo', 1, function(err, res) {
        err.should.equal('foo-error');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
  });
  describe('#getChildren', function() {
    beforeEach(function() {
      clientWithoutRoot = new SimpleClient();
      clientWithRoot = new SimpleClient({
        root: '/some/Root'
      });
      return stub = clientWithoutRoot.client.a_get_children = sinon.stub();
    });
    afterEach(function() {
      return clientWithoutRoot = clientWithRoot = stub = null;
    });
    it('calls a_get_children with full path', function(done) {
      var mock;
      mock = sinon.mock(clientWithRoot.client);
      mock.expects('a_get_children').once().withArgs('/some/Root/foo', 1).yields(null);
      return clientWithRoot.getChildren('/foo', 1, function() {
        mock.verify();
        return done();
      });
    });
    it('gives normalized result callback on ok', function(done) {
      stub.yields(0, 'foo-error', 'foo-result');
      return clientWithoutRoot.getChildren('/foo', 1, function(err, res) {
        should.not.exist(err);
        res.should.equal('foo-result');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    return it('gives normalized error callback on error', function(done) {
      stub.yields(1, 'foo-error', 'foo-result');
      return clientWithoutRoot.getChildren('/foo', 1, function(err, res) {
        err.should.equal('foo-error');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
  });
  describe('#mkdir', function() {
    beforeEach(function() {
      clientWithoutRoot = new SimpleClient();
      clientWithRoot = new SimpleClient({
        root: '/some/Root'
      });
      return stub = clientWithoutRoot.client.mkdirp = sinon.stub();
    });
    afterEach(function() {
      return clientWithoutRoot = clientWithRoot = stub = null;
    });
    it('calls mkdirp with full path', function(done) {
      var mock;
      mock = sinon.mock(clientWithRoot.client);
      mock.expects('mkdirp').once().withArgs('/some/Root/foo').yields(null);
      return clientWithRoot.mkdir('/foo', function() {
        mock.verify();
        return done();
      });
    });
    it('gives normalized result callback on ok', function(done) {
      stub.yields(null);
      return clientWithoutRoot.mkdir('/foo', function(err) {
        should.not.exist(err);
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    return it('gives normalized error callback on error', function(done) {
      stub.yields('foo-error');
      return clientWithoutRoot.mkdir('/foo', function(err) {
        err.should.equal('foo-error');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
  });
  return describe('#set', function() {
    beforeEach(function() {
      clientWithoutRoot = new SimpleClient();
      clientWithRoot = new SimpleClient({
        root: '/some/Root'
      });
      return stub = clientWithoutRoot.client.a_set = sinon.stub();
    });
    afterEach(function() {
      return clientWithoutRoot = clientWithRoot = stub = null;
    });
    it('calls a_set with full path', function(done) {
      var mock;
      mock = sinon.mock(clientWithRoot.client);
      mock.expects('a_set').once().withArgs('/some/Root/foo', 'bar', 1).yields(null);
      return clientWithRoot.set('/foo', 'bar', 1, function() {
        mock.verify();
        return done();
      });
    });
    it('gives normalized result callback on ok', function(done) {
      stub.yields(0, 'foo-error', 'foo-result');
      return clientWithoutRoot.set('/foo', 'bar', 1, function(err, res) {
        should.not.exist(err);
        res.should.equal('foo-result');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    return it('gives normalized error callback on error', function(done) {
      stub.yields(1, 'foo-error', 'foo-result');
      return clientWithoutRoot.set('/foo', 'bar', 1, function(err, res) {
        err.should.equal('foo-error');
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
  });
});

/*
//@ sourceMappingURL=SimpleClient.js.map
*/