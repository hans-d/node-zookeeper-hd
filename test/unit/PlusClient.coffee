should = require 'should'
mockery = require 'mockery'
sinon = require 'sinon'

zookeeperStub = require '../lib/zookeeperStub'

# PlusClient uses Zookeeper client, here we will use a test double for it.
# (so we can unit test without needing a zookeeper instance)
# Set up for modified require-s is done in #before

describe 'PlusClient Class', ->
  PlusClient = null
  client = mock = stub = null

  before ->
    # control require-d modules
    mockery.enable()
    mockery.registerAllowable '../../src/lib/PlusClient'        # module under test
    mockery.registerAllowables [                                # allowed require-s
      './SimpleClient', 'path', 'async', 'underscore'
    ]
    # replace modules for testing
    mockery.registerMock 'zookeeper', zookeeperStub.Client
    # load module under test, using replaced require-d modules
    PlusClient = require '../../src/lib/PlusClient'

  after ->
    mockery.deregisterAll()
    mockery.disable()

  afterEach ->
    client = mock = stub = null

  describe '#createOrUpdate', ->

    beforeEach ->
      client = new PlusClient root: '/some/Root'
      mock = sinon.mock client
      client._exists = client.exists
      stub = client.exists = sinon.stub()

    afterEach ->
      client = mock = stub = null

    it 'should update if path exists', (done) ->
      stub.yields null, true, version: 15
      mock.expects('set').once().withArgs('/foo', 'bar', 15).yields null, 'foobar'
      mock.expects('create').never()
      client.createOrUpdate '/foo', 'bar', flags: 1, watch: 2, (err, res) ->
        should.not.exist err
        res.should.equal 'foobar'
        mock.verify()
        stub.calledOnce.should.equal true
        done()

    it 'should create if path does not exist', (done) ->
      stub.yields null, false
      mock.expects('create').once().withArgs('/foo', 'bar', flags: 1, watch: 2).yields null, 'foobar'
      mock.expects('set').never()
      client.createOrUpdate '/foo', 'bar', flags: 1, watch: 2, (err, res) ->
        should.not.exist err
        res.should.equal 'foobar'
        mock.verify()
        stub.calledOnce.should.equal true
        done()

    it 'can be called without options', (done) ->
      client.exists = client._exists
      mock.expects('exists').once().withArgs('/foo', flags: null, watch: null).yields null, false
      mock.expects('create').once().withArgs('/foo', 'bar', flags: null, watch: null).yields null, 'foobar'
      client.createOrUpdate '/foo', 'bar', (err, res) ->
        mock.verify()
        done()

    it 'can be called with backwards compatible signature', (done) ->
      client.exists = client._exists
      mock.expects('exists').once().withArgs('/foo', flags: 1, watch: 2).yields null, false
      mock.expects('create').once().withArgs('/foo', 'bar', flags: 1, watch: 2).yields null, 'foobar'
      client.createOrUpdate '/foo', 'bar', 1, 2, (err, res) ->
        mock.verify()
        done()


  describe '#createPathIfNotExists', ->

    beforeEach ->
      client = new PlusClient root: '/some/Root'
      mock = sinon.mock client

    afterEach ->
      client = mock = stub = null

    it 'should always call mkdir', (done) ->
      mock.expects('mkdir').once().withArgs('/foo').yields null, 'foobar'
      client.createPathIfNotExists '/foo', (err, res) ->
        should.not.exist err
        res.should.equal 'foobar'
        mock.verify()
        done()


  describe 'methods based on SimpleClient', ->
    mockMethod = null

    afterEach ->
      mockMethod = client = mock = stub = null


    describe '#create', ->

      beforeEach ->
        client = new PlusClient root: '/some/Root'
        mock = sinon.mock client.client
        mockMethod = mock.expects('create').once()

      afterEach ->
        mockMethod = client = mock = stub = null

      it 'can be called using SimpleClient signature', (done) ->
        mockMethod.withArgs('/foo', 'bar', 1).yields null
        client.create '/foo', 'bar', 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature with options', (done) ->
        mockMethod.withArgs('/foo', 'bar', 1).yields null
        client.create '/foo', 'bar', flags: 1, test: 2, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature without options', (done) ->
        mockMethod.withArgs('/foo', 'bar', null).yields null
        client.create '/foo', 'bar', (err) ->
          mock.verify()
          done()


    describe '#exists', ->

      beforeEach ->
        client = new PlusClient root: '/some/Root'
        mock = sinon.mock client.client
        mockMethod = mock.expects('exists').once()

      afterEach ->
        mockMethod = client = mock = stub = null

      it 'can be called using SimpleClient signature', (done) ->
        mockMethod.withArgs('/foo', 1).yields null
        client.exists '/foo', 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature with options', (done) ->
        mockMethod.withArgs('/foo', 1).yields null
        client.exists '/foo', watch: 1, flags: 2, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature without options', (done) ->
        mockMethod.withArgs('/foo', null).yields null
        client.exists '/foo', (err) ->
          mock.verify()
          done()


    describe '#get', ->

      beforeEach ->
        client = new PlusClient root: '/some/Root'
        mock = sinon.mock client.client
        mockMethod = mock.expects('get').once()

      afterEach ->
        mockMethod = client = mock = stub = null

      it 'can be called using SimpleClient signature', (done) ->
        mockMethod.withArgs('/foo', 1).yields null
        client.get '/foo', 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature with options', (done) ->
        mockMethod.withArgs('/foo', 1).yields null
        client.get '/foo', watch: 1, flags: 2, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature without options', (done) ->
        mockMethod.withArgs('/foo', null).yields null
        client.get '/foo', (err) ->
          mock.verify()
          done()


    describe '#getChildren', ->

      beforeEach ->
        client = new PlusClient root: '/some/Root'
        mock = sinon.mock client.client
        mockMethod = mock.expects('getChildren').once()

      afterEach ->
        mockMethod = client = mock = stub = null

      it 'can be called using SimpleClient signature', (done) ->
        mockMethod.withArgs('/foo', 1).yields null
        client.getChildren '/foo', 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature with options', (done) ->
        mockMethod.withArgs('/foo', 1).yields null
        client.getChildren '/foo', watch: 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature without options', (done) ->
        mockMethod.withArgs('/foo', null).yields null
        client.getChildren '/foo', (err) ->
          mock.verify()
          done()

      it 'can create the root path with createPathIfNotExists', (done) ->
        mockMethod.withArgs('/foo', null).yields null
        mock.expects('mkdir').once().withArgs('/foo').yields null
        client.getChildren '/foo', createPathIfNotExists: true, (err) ->
          mock.verify()
          done()

      it 'does not create the root path without createPathIfNotExists', (done) ->
        mockMethod.withArgs('/foo', null).yields null
        mock.expects('mkdir').never()
        client.getChildren '/foo', (err) ->
          mock.verify()
          done()

    describe '#mkdir', ->

      beforeEach ->
        client = new PlusClient root: '/some/Root'
        mock = sinon.mock client.client
        mockMethod = mock.expects('mkdir').once()

      afterEach ->
        mockMethod = client = mock = stub = null

      it 'can be called using SimpleClient signature', (done) ->
        mockMethod.withArgs('/foo').yields null
        client.mkdir '/foo', (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature with options', (done) ->
        mockMethod.withArgs('/foo').yields null
        client.mkdir '/foo', watch: 1, flags: 2, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature without options', (done) ->
        mockMethod.withArgs('/foo').yields null
        client.mkdir '/foo', (err) ->
          mock.verify()
          done()


    describe '#set', ->

      beforeEach ->
        client = new PlusClient root: '/some/Root'
        mock = sinon.mock client.client
        mockMethod = mock.expects('set').once()

      afterEach ->
        client = mock = stub = null

      it 'can be called using SimpleClient signature', (done) ->
        mockMethod.withArgs('/foo', 'bar', 1).yields null
        client.set '/foo', 'bar', 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature with options', (done) ->
        mockMethod.withArgs('/foo', 'bar', 1).yields null
        client.set '/foo', 'bar', 1, flags: 1, test: 2, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature without options', (done) ->
        mockMethod.withArgs('/foo', 'bar', 1).yields null
        client.set '/foo', 'bar', 1, (err) ->
          mock.verify()
          done()
