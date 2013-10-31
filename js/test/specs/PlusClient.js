// This file has been generated from coffee source files

var FakeZookeeper, mockery, should, sinon;

should = require('should');

sinon = require('sinon');

mockery = require('mockery');

FakeZookeeper = require('../../src/lib/FakeZookeeper');

describe('PlusClient Class', function() {
  var PlusClient, client, mock, stub;
  PlusClient = null;
  client = mock = stub = null;
  before(function() {
    var _ref;
    mockery.enable({
      useCleanCache: true
    });
    mockery.registerMock('zookeeper', FakeZookeeper);
    mockery.registerAllowables(['async', 'underscore', 'path', 'events', '..', '../../src/', './lib/PlusClient', './lib/SimpleClient', './lib/FakeZookeeper']);
    return _ref = require('../../src/'), PlusClient = _ref.PlusClient, _ref;
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
    return it('can be called without options', function(done) {
      client.exists = client._exists;
      mock.expects('exists').once().withArgs('/foo').yields(null, false);
      mock.expects('create').once().withArgs('/foo', 'bar').yields(null, 'foobar');
      return client.createOrUpdate('/foo', 'bar', function(err, res) {
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
      it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        return client.get('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
      it('can create the root path with createPathIfNotExists', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        mock.expects('mkdir').once().withArgs('/foo').yields(null);
        return client.get('/foo', {
          createPathIfNotExists: true
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      return it('does not create the root path without createPathIfNotExists', function(done) {
        mockMethod.withArgs('/foo', null).yields(null);
        mock.expects('mkdir').never();
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
        mockMethod.withArgs('/foo', 1).yields(null, ['bar']);
        return client.getChildren('/foo', 1, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature with options', function(done) {
        mockMethod.withArgs('/foo', 1).yields(null, ['bar']);
        return client.getChildren('/foo', {
          watch: 1
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      it('can be called using plus signature without options', function(done) {
        mockMethod.withArgs('/foo', null).yields(null, ['bar']);
        return client.getChildren('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
      it('can create the root path with createPathIfNotExists', function(done) {
        mockMethod.withArgs('/foo', null).yields(null, ['bar']);
        mock.expects('mkdir').once().withArgs('/foo').yields(null);
        return client.getChildren('/foo', {
          createPathIfNotExists: true
        }, function(err) {
          mock.verify();
          return done();
        });
      });
      it('does not create the root path without createPathIfNotExists', function(done) {
        mockMethod.withArgs('/foo', null).yields(null, ['bar']);
        mock.expects('mkdir').never();
        return client.getChildren('/foo', function(err) {
          mock.verify();
          return done();
        });
      });
      it('can retrieve the child values with getChildData', function(done) {
        mockMethod.withArgs('/foo', null).yields(null, ['foo', 'bar']);
        mock.expects('joinPath').once().withArgs('/foo', 'foo').returns('/foo/foo');
        mock.expects('joinPath').once().withArgs('/foo', 'bar').returns('/foo/bar');
        mock.expects('get').once().withArgs('/foo/foo').yields(null, {}, "foo-result");
        mock.expects('get').once().withArgs('/foo/bar').yields(null, {}, "bar-result");
        return client.getChildren('/foo', {
          getChildData: true
        }, function(err, res) {
          should.not.exist(err);
          res.should.eql({
            foo: "foo-result",
            bar: "bar-result"
          });
          mock.verify();
          return done();
        });
      });
      it('does not retrieve the child values without getChildData', function(done) {
        mockMethod.withArgs('/foo', null).yields(null, ['foo', 'bar']);
        return client.getChildren('/foo', function(err, res) {
          res.should.eql(['foo', 'bar']);
          mock.verify();
          return done();
        });
      });
      it('can retrieve the child values of lower levels with getChildData', function(done) {
        mockMethod.withArgs('/foo', null).yields(null, ['foo', 'bar']);
        mock.expects('getChildren').once().withArgs('/foo/foo', null).yields(null, ['foo1', 'foo2']);
        mock.expects('getChildren').once().withArgs('/foo/bar', null).yields(null, ['bar1', 'bar2']);
        mock.expects('joinPath').once().withArgs('/foo', 'foo').returns('/foo/foo');
        mock.expects('joinPath').once().withArgs('/foo/foo', 'foo1').returns('/foo/foo/foo1');
        mock.expects('joinPath').once().withArgs('/foo/foo', 'foo2').returns('/foo/foo/foo2');
        mock.expects('joinPath').once().withArgs('/foo', 'bar').returns('/foo/bar');
        mock.expects('joinPath').once().withArgs('/foo/bar', 'bar1').returns('/foo/bar/bar1');
        mock.expects('joinPath').once().withArgs('/foo/bar', 'bar2').returns('/foo/bar/bar2');
        mock.expects('get').once().withArgs('/foo/foo/foo1').yields(null, {}, "foo-result1");
        mock.expects('get').once().withArgs('/foo/foo/foo2').yields(null, {}, "foo-result2");
        mock.expects('get').once().withArgs('/foo/bar/bar1').yields(null, {}, "bar-result1");
        mock.expects('get').once().withArgs('/foo/bar/bar2').yields(null, {}, "bar-result2");
        return client.getChildren('/foo', {
          getChildData: true,
          levels: 2
        }, function(err, res) {
          should.not.exist(err);
          res.should.eql({
            foo: {
              foo1: "foo-result1",
              foo2: "foo-result2"
            },
            bar: {
              bar1: "bar-result1",
              bar2: "bar-result2"
            }
          });
          mock.verify();
          return done();
        });
      });
      return it('does not retrieve the child values of lower levels without getChildData', function(done) {
        mockMethod.withArgs('/foo', null).yields(null, ['foo', 'bar']);
        mock.expects('getChildren').once().withArgs('/foo/foo', null).yields(null, ['foo1', 'foo2']);
        mock.expects('getChildren').once().withArgs('/foo/bar', null).yields(null, ['bar1', 'bar2']);
        mock.expects('joinPath').once().withArgs('/foo', 'foo').returns('/foo/foo');
        mock.expects('joinPath').once().withArgs('/foo', 'bar').returns('/foo/bar');
        return client.getChildren('/foo', {
          levels: 2
        }, function(err, res) {
          should.not.exist(err);
          res.should.eql({
            foo: ['foo1', 'foo2'],
            bar: ['bar1', 'bar2']
          });
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