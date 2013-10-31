// This file has been generated from coffee source files

var FakeZookeeper, should;

should = require('should');

FakeZookeeper = require('../../src/lib/FakeZookeeper');

describe('Fake Zookeeper', function() {
  var zk;
  zk = null;
  beforeEach(function() {
    zk = new FakeZookeeper();
    zk.a_create('/foo', 'bar', 0, function() {});
    return zk.a_create('/foo/foo', 'bar', 0, function() {});
  });
  describe('construction', function() {
    it('can be created', function() {
      zk = new FakeZookeeper();
      return should.exist(zk);
    });
    it('should have a registry', function() {
      zk = new FakeZookeeper();
      return should.exist(zk.registry);
    });
    return it('should have only a root', function() {
      zk = new FakeZookeeper();
      return zk.registry._nodes.should.have.keys('/');
    });
  });
  describe('#a_create', function() {
    beforeEach(function() {
      return zk = new FakeZookeeper();
    });
    it('should create a new path', function(done) {
      return zk.a_create('/foo', 'bar', null, function(rc, err, p) {
        zk.registry._nodes.should.have.keys('/', '/foo');
        return done();
      });
    });
    it('should return the path when creating a new path', function(done) {
      return zk.a_create('/foo', 'bar', null, function(rc, err, p) {
        zk.registry._nodes.should.have.keys('/', '/foo');
        rc.should.equal(0);
        p.should.equal('/foo');
        return done();
      });
    });
    it('should set the value of the node', function(done) {
      return zk.a_create('/foo', 'bar', null, function(rc, err, p) {
        zk.registry._nodes['/foo'].should.include({
          value: 'bar'
        });
        return done();
      });
    });
    it('should set the flags of the node', function(done) {
      return zk.a_create('/foo', 'bar', 123, function(rc, err, p) {
        zk.registry._nodes['/foo'].should.include({
          flags: 123
        });
        return done();
      });
    });
    it('should set the version of the node to 1', function(done) {
      return zk.a_create('/foo', 'bar', 123, function(rc, err, p) {
        zk.registry._nodes['/foo'].should.include({
          version: 1
        });
        return done();
      });
    });
    it('should fail with node exists when creating an existing path', function(done) {
      zk.a_create('/foo', 'bar', null, function() {});
      return zk.a_create('/foo', 'bar', null, function(rc, err, p) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNODEEXISTS);
        err.should.equal('node exists');
        return done();
      });
    });
    it('should create a new sub path when parrent exists', function(done) {
      return zk.a_create('/foo', 'bar', null, function(rc, err, p) {
        zk.registry._nodes.should.have.keys('/', '/foo');
        return zk.a_create('/foo/foo', 'bar', null, function(rc, err, p) {
          zk.registry._nodes.should.have.keys('/', '/foo', '/foo/foo');
          return done();
        });
      });
    });
    return it('should fail with no node when creating a path with no existing parent', function(done) {
      return zk.a_create('/foo/foo', 'bar', null, function(rc, err, p) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal('no node');
        return done();
      });
    });
  });
  describe('#a_delete', function() {
    it('should delete an existing node using version -1', function(done) {
      return zk.a_delete('/foo/foo', -1, function(rc, err) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        zk.registry._nodes.should.have.keys('/', '/foo');
        return done();
      });
    });
    it('should delete an existing node using correct version', function(done) {
      return zk.a_delete('/foo/foo', 1, function(rc, err) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        zk.registry._nodes.should.have.keys('/', '/foo');
        return done();
      });
    });
    it('should fail with no node when deleting a non-existing node', function(done) {
      return zk.a_delete('/bar', -1, function(rc, err) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal('no node');
        return done();
      });
    });
    it('should fail with bad version when using incorrect version', function(done) {
      return zk.a_delete('/foo/foo', 99, function(rc, err) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZBADVERSION);
        err.should.equal('bad version');
        return done();
      });
    });
    return it('should fail with not empty when deleting a node with children', function(done) {
      return zk.a_delete('/foo', -1, function(rc, err) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNOTEMPTY);
        err.should.equal('not empty');
        return done();
      });
    });
  });
  describe('#a_exists', function() {
    it('should return the node stat', function(done) {
      return zk.a_exists('/foo/foo', false, function(rc, err, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        stat.should.eql({
          version: 1
        });
        return done();
      });
    });
    it('should fail with no node if not exists', function(done) {
      return zk.a_exists('/bar', false, function(rc, err, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal('no node');
        return done();
      });
    });
    return it('should set a watch');
  });
  describe('#aw_exists', function() {
    it('should return the node stat', function(done) {
      return zk.a_exists('/foo/foo', false, function(rc, err, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        stat.should.eql({
          version: 1
        });
        return done();
      });
    });
    it('should fail with no node if not exists', function(done) {
      return zk.a_exists('/bar', false, function(rc, err, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal('no node');
        return done();
      });
    });
    return it('should set a watch');
  });
  describe('#a_get', function() {
    it("should return stat and value", function(done) {
      return zk.a_get('/foo/foo', false, function(rc, err, stat, value) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        stat.should.eql({
          version: 1
        });
        value.should.equal('bar');
        return done();
      });
    });
    it("should fail with no node if path does not exist", function(done) {
      return zk.a_get('/foo/bar', false, function(rc, err, stat, value) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal("no node");
        return done();
      });
    });
    return it("should set a watch");
  });
  describe('#aw_get', function() {
    it("should return stat and value", function(done) {
      return zk.aw_get('/foo/foo', false, function(rc, err, stat, value) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        stat.should.eql({
          version: 1
        });
        value.should.equal('bar');
        return done();
      });
    });
    it("should fail with no node if path does not exist", function(done) {
      return zk.aw_get('/foo/bar', false, function(rc, err, stat, value) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal("no node");
        return done();
      });
    });
    return it("should set a watch");
  });
  describe('#a_get_children', function() {
    it("should return the known children", function(done) {
      return zk.a_get_children('/foo', false, function(rc, err, children) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql(['foo']);
        return done();
      });
    });
    it("should return [] if there a no known children", function(done) {
      return zk.a_get_children('/foo/foo', false, function(rc, err, children) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql([]);
        return done();
      });
    });
    it("should fail with no node if path does not exist", function(done) {
      return zk.a_get_children('/bar', false, function(rc, err, children) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal("no node");
        return done();
      });
    });
    return it("should set a watch");
  });
  describe('#aw_get_children', function() {
    it("should return the known children", function(done) {
      return zk.aw_get_children('/foo', false, function(rc, err, children) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql(['foo']);
        return done();
      });
    });
    it("should return [] if there a no known children", function(done) {
      return zk.aw_get_children('/foo/foo', false, function(rc, err, children) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql([]);
        return done();
      });
    });
    it("should fail with no node if path does not exist", function(done) {
      return zk.aw_get_children('/bar', false, function(rc, err, children) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal("no node");
        return done();
      });
    });
    return it("should set a watch");
  });
  describe('#a_get_children2', function() {
    it("should return the known children and the node stat", function(done) {
      return zk.a_get_children2('/foo', false, function(rc, err, children, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql(['foo']);
        stat.should.eql({
          version: 1
        });
        return done();
      });
    });
    it("should return stat and [] if there a no known children", function(done) {
      return zk.a_get_children2('/foo/foo', false, function(rc, err, children, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql([]);
        stat.should.eql({
          version: 1
        });
        return done();
      });
    });
    it("should fail with no node if path does not exist", function(done) {
      return zk.a_get_children2('/bar', false, function(rc, err, children, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal("no node");
        return done();
      });
    });
    return it("should set a watch");
  });
  describe('#aw_get_children2', function() {
    it("should return the known children and the node stat", function(done) {
      return zk.aw_get_children2('/foo', false, function(rc, err, children, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql(['foo']);
        stat.should.eql({
          version: 1
        });
        return done();
      });
    });
    it("should return stat and [] if there a no known children", function(done) {
      return zk.aw_get_children2('/foo/foo', false, function(rc, err, children, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        children.should.eql([]);
        stat.should.eql({
          version: 1
        });
        return done();
      });
    });
    it("should fail with no node if path does not exist", function(done) {
      return zk.aw_get_children2('/bar', false, function(rc, err, children, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal("no node");
        return done();
      });
    });
    return it("should set a watch");
  });
  describe('#a_set', function() {
    it('should update an existing node using version -1', function(done) {
      return zk.a_set('/foo/foo', 'bar2', -1, function(rc, err, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        return zk.a_get('/foo/foo', false, function(rc, err, stat, value) {
          value.should.equal('bar2');
          return done();
        });
      });
    });
    it('should update an existing node using correct version', function(done) {
      return zk.a_set('/foo/foo', 'bar2', 1, function(rc, err, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZOK);
        return zk.a_get('/foo/foo', false, function(rc, err, stat, value) {
          value.should.equal('bar2');
          return done();
        });
      });
    });
    it('should return the new stat after update', function(done) {
      return zk.a_set('/foo/foo', 'bar2', -1, function(rc, err, stat) {
        stat.should.eql({
          version: 2
        });
        zk.a_get('/foo/foo', false, function(rc, err, stat, value) {});
        stat.should.eql({
          version: 2
        });
        return done();
      });
    });
    it('should fail with no node when updating a non-existing node', function(done) {
      return zk.a_set('/bar', 'bar2', -1, function(rc, err, stat) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZNONODE);
        err.should.equal('no node');
        return done();
      });
    });
    return it('should fail with bad version when using incorrect version', function(done) {
      return zk.a_set('/foo/foo', 'bar2', 99, function(rc, err) {
        rc.should.equal(FakeZookeeper.ZKCONST.ZBADVERSION);
        err.should.equal('bad version');
        return done();
      });
    });
  });
  return describe('#mkdirp', function() {
    return it("should create all missing parents", function(done) {
      return zk.mkdirp('/some/very/long/path', function(err) {
        should.not.exist(err);
        zk.registry._nodes.should.have.keys('/', '/foo', '/foo/foo', '/some', '/some/very', '/some/very/long', '/some/very/long/path');
        return done();
      });
    });
  });
});

/*
//@ sourceMappingURL=FakeZookeeper.js.map
*/