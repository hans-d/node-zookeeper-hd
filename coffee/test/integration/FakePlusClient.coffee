should = require 'should'
sinon = require 'sinon'
mockery = require 'mockery'

describe 'PlusClient with a FakeZookeeper', ->
  PlusClient = null
  client = zk = null

  before ->
    # control require-d modules
    mockery.enable useCleanCache: true
    mockery.registerAllowables [
      '../../src/lib/PlusClient',
      './SimpleClient',
      'path', 'events',
      'async', 'underscore'
    ]

    # replace modules for testing
    mockery.registerSubstitute 'zookeeper', '../../src/lib/FakeZookeeper'
    #    load module under test, using replaced require-d modules
    PlusClient = require '../../src/lib/PlusClient'

  after ->
    mockery.deregisterAll()
    mockery.disable()

  beforeEach ->
    client = new PlusClient()
    zk = client.client.client

  afterEach ->
    client = null

  describe 'Test setup', ->

    it 'should have a client (SimpleClient)', ->
      should.exist client.client
      client.client.constructor.name.should.equal 'SimpleClient'

    it 'should have a nested client (FakeZookeeper)', ->
      should.exist client.client.client
      client.client.client.constructor.name.should.equal 'FakeZookeeper'
      client.client.client.should.equal zk

  describe 'Zookeeper client actions', ->

    beforeEach (done) ->
      client.create '/foo', 'bar', (err) ->
        should.not.exist err
        done()

    describe '#create', ->

      beforeEach ->
        client = new PlusClient()
        zk = client.client.client

      it 'can create a node', (done) ->
        client.create '/foo', 'bar', flags: 1, (err) ->
          should.not.exist err
          zk.registry._nodes.should.have.keys '/', '/foo'
          done()

      it 'should contain the correct data', (done) ->
        client.create '/foo', 'bar', flags: 1, (err) ->
          should.not.exist err
          zk.registry._nodes['/foo'].should.include value: 'bar', flags: 1
          done()

      it 'can create a node with missing parents', (done) ->
        client.create '/foo/bar/awesome', 'bar', flags: 1, createPathIfNotExists: true, (err) ->
          should.not.exist err
          zk.registry._nodes.should.have.keys '/', '/foo', '/foo/bar', '/foo/bar/awesome'
          done()

      it 'can be retrieved with a get', (done) ->
        client.create '/foo', 'bar', (err) ->
          should.not.exist err
          client.get '/foo', (err, stat, value) ->
            should.not.exist err
            value.should.equal 'bar'
            done()

    describe '#exists', ->

      it 'returns true and stat if exists', (done) ->
        client.exists '/foo', (err, exists, stat) ->
          should.not.exist err
          exists.should.be.true
          stat.should.eql version: 1
          done()

      it 'returns false if not exists', (done) ->
        client.exists '/foo2', (err, exists, stat) ->
          should.not.exist err
          exists.should.be.false
          done()

    describe '#get', ->

      it 'can retrieve', (done) ->
        client.get '/foo', (err, stat, value) ->
          should.not.exist err
          value.should.equal 'bar'
          done()

    describe '#getChildren', ->

      beforeEach (done) ->
        client.create '/foo/foo', 'foo-result', (err) ->
          should.not.exist err
          client.create '/foo/bar', 'bar-result', (err) ->
            should.not.exist err
            done()

      it 'can retrieve the child values with getChildData', (done) ->
        client.getChildren '/foo', getChildData: true, (err, res) ->
          should.not.exist err
          res.should.eql foo: "foo-result", bar: "bar-result"
          done()

    describe '#mkdir', ->

      it 'can create a node with all its parents', (done) ->
        client.mkdir '/some/long/path', (err) ->
          should.not.exist err

          client.exists '/some/long/path', (err, exists, stat) ->
            should.not.exist err
            exists.should.be.true
            done()

    describe '#set', ->

      it 'can update an existing node'

    describe '#createOrUpdate', ->

      it 'can update an existing node'
      it 'can create a new node'

    describe '#createPathIfNotExists', ->

      it 'can create a path if not exists'
      it 'doen not fail when the path already exists'

