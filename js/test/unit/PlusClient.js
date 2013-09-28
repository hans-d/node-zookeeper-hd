// This file has been generated from coffee source files

var mockery, should, sinon, zookeeperStub;

should = require('should');

mockery = require('mockery');

sinon = require('sinon');

zookeeperStub = require('../lib/zookeeperStub');

describe('PlusClient Class', function() {
  var PlusClient, client, mock, stub;
  PlusClient = null;
  client = mock = stub = null;
  before(function() {
    mockery.enable();
    mockery.registerAllowable('../../src/lib/PlusClient');
    mockery.registerAllowables(['./SimpleClient', 'path', 'async', 'underscore']);
    mockery.registerMock('zookeeper', zookeeperStub.Client);
    return PlusClient = require('../../src/lib/PlusClient');
  });
  after(function() {
    mockery.deregisterAll();
    return mockery.disable();
  });
  afterEach(function() {
    return client = mock = stub = null;
  });
  describe('#createOrUpdate', function() {
    beforeEach(function() {
      client = new PlusClient({
        root: '/some/Root'
      });
      mock = sinon.mock(client);
      client._exists = client.exists;
      return stub = client.exists = sinon.stub();
    });
    afterEach(function() {
      return client = mock = stub = null;
    });
    it('should update if path exists', function(done) {
      stub.yields(null, true, {
        version: 15
      });
      mock.expects('set').once().withArgs('/foo', 'bar', 15).yields(null, 'foobar');
      mock.expects('create').never();
      return client.createOrUpdate('/foo', 'bar', {
        flags: 1,
        watch: 2
      }, function(err, res) {
        should.not.exist(err);
        res.should.equal('foobar');
        mock.verify();
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    it('should create if path does not exist', function(done) {
      stub.yields(null, false);
      mock.expects('create').once().withArgs('/foo', 'bar', {
        flags: 1,
        watch: 2
      }).yields(null, 'foobar');
      mock.expects('set').never();
      return client.createOrUpdate('/foo', 'bar', {
        flags: 1,
        watch: 2
      }, function(err, res) {
        should.not.exist(err);
        res.should.equal('foobar');
        mock.verify();
        stub.calledOnce.should.equal(true);
        return done();
      });
    });
    it('can be called without options', function(done) {
      client.exists = client._exists;
      mock.expects('exists').once().withArgs('/foo', {
        flags: null,
        watch: null
      }).yields(null, false);
      mock.expects('create').once().withArgs('/foo', 'bar', {
        flags: null,
        watch: null
      }).yields(null, 'foobar');
      return client.createOrUpdate('/foo', 'bar', function(err, res) {
        mock.verify();
        return done();
      });
    });
    return it('can be called with backwards compatible signature', function(done) {
      client.exists = client._exists;
      mock.expects('exists').once().withArgs('/foo', {
        flags: 1,
        watch: 2
      }).yields(null, false);
      mock.expects('create').once().withArgs('/foo', 'bar', {
        flags: 1,
        watch: 2
      }).yields(null, 'foobar');
      return client.createOrUpdate('/foo', 'bar', 1, 2, function(err, res) {
        mock.verify();
        return done();
      });
    });
  });
  describe('#createPathIfNotExists', function() {
    beforeEach(function() {
      client = new PlusClient({
        root: '/some/Root'
      });
      return mock = sinon.mock(client);
    });
    afterEach(function() {
      return client = mock = stub = null;
    });
    return it('should always call mkdir', function(done) {
      mock.expects('mkdir').once().withArgs('/foo').yields(null, 'foobar');
      return client.createPathIfNotExists('/foo', function(err, res) {
        should.not.exist(err);
        res.should.equal('foobar');
        mock.verify();
        return done();
      });
    });
  });
  return describe('methods based on SimpleClient', function() {
    var mockMethod;
    mockMethod = null;
    afterEach(function() {
      return mockMethod = client = mock = stub = null;
    });
    describe('#create', function() {
      beforeEach(function() {
        client = new PlusClient({
          root: '/some/Root'
        });
        mock = sinon.mock(client.client);
        return mockMethod = mock.expects('create').once();
      });
      afterEach(function() {
        return mockMethod = client = mock = stub = null;
      });
      it('can be called using SimpleClient signature', function(done) {
        mockMethod.withArgs('/foo', 'bar', 1).yields(null);
        return client.create('/foo', 'bar', 1, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature with options', function(done) {
        mockMethod.withArgs('/foo', 'bar', 1).yields(null);
        return client.create('/foo', 'bar', {
          flags: 1,
          test: 2
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      return it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo', 'bar', null).yields(null);
        return client.create('/foo', 'bar', function(err) {
          mock.verify();
          return done();
        });
      });
    });
    describe('#exists', function() {
      beforeEach(function() {
        client = new PlusClient({
          root: '/some/Root'
        });
        mock = sinon.mock(client.client);
        return mockMethod = mock.expects('exists').once();
      });
      afterEach(function() {
        return mockMethod = client = mock = stub = null;
      });
      it('can be called using SimpleClient signature', function(done) {
        mockMethod.withArgs('/foo', 1).yields(null);
        return client.exists('/foo', 1, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature with options', function(done) {
        mockMethod.withArgs('/foo', 1).yields(null);
        return client.exists('/foo', {
          watch: 1,
          flags: 2
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      return it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        return client.exists('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
    });
    describe('#get', function() {
      beforeEach(function() {
        client = new PlusClient({
          root: '/some/Root'
        });
        mock = sinon.mock(client.client);
        return mockMethod = mock.expects('get').once();
      });
      afterEach(function() {
        return mockMethod = client = mock = stub = null;
      });
      it('can be called using SimpleClient signature', function(done) {
        mockMethod.withArgs('/foo', 1).yields(null);
        return client.get('/foo', 1, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature with options', function(done) {
        mockMethod.withArgs('/foo', 1).yields(null);
        return client.get('/foo', {
          watch: 1,
          flags: 2
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      return it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        return client.get('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
    });
    describe('#getChildren', function() {
      beforeEach(function() {
        client = new PlusClient({
          root: '/some/Root'
        });
        mock = sinon.mock(client.client);
        return mockMethod = mock.expects('getChildren').once();
      });
      afterEach(function() {
        return mockMethod = client = mock = stub = null;
      });
      it('can be called using SimpleClient signature', function(done) {
        mockMethod.withArgs('/foo', 1).yields(null);
        return client.getChildren('/foo', 1, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature with options', function(done) {
        mockMethod.withArgs('/foo', 1).yields(null);
        return client.getChildren('/foo', {
          watch: 1
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        return client.getChildren('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
      it('can create the root path with createPathIfNotExists', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        mock.expects('mkdir').once().withArgs('/foo').yields(null);
        return client.getChildren('/foo', {
          createPathIfNotExists: true
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      return it('does not create the root path without createPathIfNotExists', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        mock.expects('mkdir').never();
        return client.getChildren('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
    });
    describe('#mkdir', function() {
      beforeEach(function() {
        client = new PlusClient({
          root: '/some/Root'
        });
        mock = sinon.mock(client.client);
        return mockMethod = mock.expects('mkdir').once();
      });
      afterEach(function() {
        return mockMethod = client = mock = stub = null;
      });
      it('can be called using SimpleClient signature', function(done) {
        mockMethod.withArgs('/foo').yields(null);
        return client.mkdir('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature with options', function(done) {
        mockMethod.withArgs('/foo').yields(null);
        return client.mkdir('/foo', {
          watch: 1,
          flags: 2
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      return it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo').yields(null);
        return client.mkdir('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
    });
    return describe('#set', function() {
      beforeEach(function() {
        client = new PlusClient({
          root: '/some/Root'
        });
        mock = sinon.mock(client.client);
        return mockMethod = mock.expects('set').once();
      });
      afterEach(function() {
        return client = mock = stub = null;
      });
      it('can be called using SimpleClient signature', function(done) {
        mockMethod.withArgs('/foo', 'bar', 1).yields(null);
        return client.set('/foo', 'bar', 1, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature with options', function(done) {
        mockMethod.withArgs('/foo', 'bar', 1).yields(null);
        return client.set('/foo', 'bar', 1, {
          flags: 1,
          test: 2
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      return it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo', 'bar', 1).yields(null);
        return client.set('/foo', 'bar', 1, function(err) {
          mock.verify();
          return done();
        });
      });
    });
  });
});

/*
//@ sourceMappingURL=PlusClient.js.map
*/