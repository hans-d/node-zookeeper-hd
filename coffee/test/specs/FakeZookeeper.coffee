should = require 'should'
FakeZookeeper = require '../../src/lib/FakeZookeeper'

describe 'Fake Zookeeper', ->
  zk = null

  beforeEach ->
    zk = new FakeZookeeper()
    zk.a_create '/foo', 'bar', 0, -> #nothing
    zk.a_create '/foo/foo', 'bar', 0, -> #nothing

  describe 'construction', ->

    it 'can be created', ->
      zk = new FakeZookeeper()
      should.exist zk

    it 'should have a registry', ->
      zk = new FakeZookeeper();
      should.exist zk.registry

    it 'should have only a root', ->
      zk = new FakeZookeeper();
      zk.registry._nodes.should.have.keys '/'

  describe '#a_create', ->

    beforeEach ->
      zk = new FakeZookeeper();

    it 'should create a new path', (done) ->
      zk.a_create '/foo', 'bar', null, (rc, err, p) ->
        zk.registry._nodes.should.have.keys '/', '/foo'
        done()

    it 'should return the path when creating a new path', (done) ->
      zk.a_create '/foo', 'bar', null, (rc, err, p) ->
        zk.registry._nodes.should.have.keys '/', '/foo'
        rc.should.equal 0
        p.should.equal '/foo'
        done()

    it 'should set the value of the node', (done) ->
      zk.a_create '/foo', 'bar', null, (rc, err, p) ->
        zk.registry._nodes['/foo'].should.include value: 'bar'
        done()

    it 'should set the flags of the node', (done) ->
      zk.a_create '/foo', 'bar', 123, (rc, err, p) ->
        zk.registry._nodes['/foo'].should.include flags: 123
        done()

    it 'should set the version of the node to 1', (done) ->
      zk.a_create '/foo', 'bar', 123, (rc, err, p) ->
        zk.registry._nodes['/foo'].should.include version: 1
        done()

    it 'should fail with node exists when creating an existing path', (done) ->
      zk.a_create '/foo', 'bar', null, ->
      zk.a_create '/foo', 'bar', null, (rc, err, p) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNODEEXISTS
        err.should.equal 'node exists'
        done()

    it 'should create a new sub path when parrent exists', (done) ->
      zk.a_create '/foo', 'bar', null, (rc, err, p) ->
        zk.registry._nodes.should.have.keys '/', '/foo'

        zk.a_create '/foo/foo', 'bar', null, (rc, err, p) ->
          zk.registry._nodes.should.have.keys '/', '/foo', '/foo/foo'
          done()

    it 'should fail with no node when creating a path with no existing parent', (done) ->
      zk.a_create '/foo/foo', 'bar', null, (rc, err, p) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal 'no node'
        done()


  describe '#a_delete', ->

    it 'should delete an existing node using version -1', (done) ->
      zk.a_delete '/foo/foo', -1, (rc, err) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        zk.registry._nodes.should.have.keys '/', '/foo'
        done()

    it 'should delete an existing node using correct version', (done) ->
      zk.a_delete '/foo/foo', 1, (rc, err) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        zk.registry._nodes.should.have.keys '/', '/foo'
        done()

    it 'should fail with no node when deleting a non-existing node', (done) ->
      zk.a_delete '/bar', -1, (rc, err) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal 'no node'
        done()

    it 'should fail with bad version when using incorrect version', (done) ->
      zk.a_delete '/foo/foo', 99, (rc, err) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZBADVERSION
        err.should.equal 'bad version'
        done()

    it 'should fail with not empty when deleting a node with children', (done) ->
      zk.a_delete '/foo', -1, (rc, err) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNOTEMPTY
        err.should.equal 'not empty'
        done()

  describe '#a_exists', ->

    it 'should return the node stat', (done) ->
      zk.a_exists '/foo/foo', false, (rc, err, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        stat.should.eql { version: 1 }
        done()

    it 'should fail with no node if not exists', (done) ->
      zk.a_exists '/bar', false, (rc, err, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal 'no node'
        done()

    it 'should set a watch'

  describe '#aw_exists', ->

    it 'should return the node stat', (done) ->
      zk.a_exists '/foo/foo', false, (rc, err, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        stat.should.eql { version: 1 }
        done()

    it 'should fail with no node if not exists', (done) ->
      zk.a_exists '/bar', false, (rc, err, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal 'no node'
        done()

    it 'should set a watch'

  describe '#a_get', ->

    it "should return stat and value", (done) ->
      zk.a_get '/foo/foo', false, (rc, err, stat, value) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        stat.should.eql version: 1
        value.should.equal 'bar'
        done()


    it "should fail with no node if path does not exist", (done) ->
      zk.a_get '/foo/bar', false, (rc, err, stat, value) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal "no node"
        done()

    it "should set a watch"

  describe '#aw_get', ->

    it "should return stat and value", (done) ->
      zk.aw_get '/foo/foo', false, (rc, err, stat, value) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        stat.should.eql version: 1
        value.should.equal 'bar'
        done()


    it "should fail with no node if path does not exist", (done) ->
      zk.aw_get '/foo/bar', false, (rc, err, stat, value) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal "no node"
        done()

    it "should set a watch"

  describe '#a_get_children', ->

    it "should return the known children", (done) ->
      zk.a_get_children '/foo', false, (rc, err, children) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql ['foo']
        done()

    it "should return [] if there a no known children", (done) ->
      zk.a_get_children '/foo/foo', false, (rc, err, children) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql []
        done()

    it "should fail with no node if path does not exist", (done) ->
      zk.a_get_children '/bar', false, (rc, err, children) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal "no node"
        done()

    it "should set a watch"

  describe '#aw_get_children', ->

    it "should return the known children", (done) ->
      zk.aw_get_children '/foo', false, (rc, err, children) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql ['foo']
        done()

    it "should return [] if there a no known children", (done) ->
      zk.aw_get_children '/foo/foo', false, (rc, err, children) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql []
        done()

    it "should fail with no node if path does not exist", (done) ->
      zk.aw_get_children '/bar', false, (rc, err, children) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal "no node"
        done()

    it "should set a watch"

  describe '#a_get_children2', ->

    it "should return the known children and the node stat", (done) ->
      zk.a_get_children2 '/foo', false, (rc, err, children, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql ['foo']
        stat.should.eql { version: 1 }
        done()

    it "should return stat and [] if there a no known children", (done) ->
      zk.a_get_children2 '/foo/foo', false, (rc, err, children, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql []
        stat.should.eql { version: 1 }
        done()

    it "should fail with no node if path does not exist", (done) ->
      zk.a_get_children2 '/bar', false, (rc, err, children, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal "no node"
        done()

    it "should set a watch"

  describe '#aw_get_children2', ->

    it "should return the known children and the node stat", (done) ->
      zk.aw_get_children2 '/foo', false, (rc, err, children, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql ['foo']
        stat.should.eql { version: 1 }
        done()

    it "should return stat and [] if there a no known children", (done) ->
      zk.aw_get_children2 '/foo/foo', false, (rc, err, children, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK
        children.should.eql []
        stat.should.eql { version: 1 }
        done()

    it "should fail with no node if path does not exist", (done) ->
      zk.aw_get_children2 '/bar', false, (rc, err, children, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal "no node"
        done()

    it "should set a watch"

  describe '#a_set', ->

    it 'should update an existing node using version -1', (done) ->
      zk.a_set '/foo/foo', 'bar2', -1, (rc, err, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK

        zk.a_get '/foo/foo', false, (rc, err, stat, value) ->
          value.should.equal 'bar2'
          done()


    it 'should update an existing node using correct version', (done) ->
      zk.a_set '/foo/foo','bar2', 1, (rc, err, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZOK

        zk.a_get '/foo/foo', false, (rc, err, stat, value) ->
          value.should.equal 'bar2'
          done()

    it 'should return the new stat after update', (done) ->
      zk.a_set '/foo/foo', 'bar2', -1, (rc, err, stat) ->
        stat.should.eql { version: 2 }

        zk.a_get '/foo/foo', false, (rc, err, stat, value) ->
        stat.should.eql { version: 2 }
        done()


    it 'should fail with no node when updating a non-existing node', (done) ->
      zk.a_set '/bar', 'bar2', -1, (rc, err, stat) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZNONODE
        err.should.equal 'no node'
        done()

    it 'should fail with bad version when using incorrect version', (done) ->
      zk.a_set '/foo/foo', 'bar2', 99, (rc, err) ->
        rc.should.equal FakeZookeeper.ZKCONST.ZBADVERSION
        err.should.equal 'bad version'
        done()


  describe '#mkdirp', ->

    it "should create all missing parents", (done) ->

      zk.mkdirp '/some/very/long/path', (err) ->
        should.not.exist err
        zk.registry._nodes.should.have.keys '/', '/foo', '/foo/foo',
          '/some', '/some/very', '/some/very/long', '/some/very/long/path'
        done()