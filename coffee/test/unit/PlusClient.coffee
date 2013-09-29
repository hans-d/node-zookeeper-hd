should = require 'should'
sinon = require 'sinon'
mockery = require 'mockery'
SimpleClientStub = require '../lib/simpleClientStub'


describe 'PlusClient Class', ->
  PlusClient = null
  client = mock = stub = null

  before ->
    # control require-d modules
    mockery.enable useCleanCache: true
    mockery.registerAllowables ['../../src/lib/PlusClient', 'async', 'underscore' ]

    # replace modules for testing
    mockery.registerMock './SimpleClient', SimpleClientStub
#    load module under test, using replaced require-d modules
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
        mockMethod.withArgs('/foo', 1).yields null, ['bar']
        client.getChildren '/foo', 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature with options', (done) ->
        mockMethod.withArgs('/foo', 1).yields null, ['bar']
        client.getChildren '/foo', watch: 1, (err) ->
          mock.verify()
          done()

      it 'can be called using plus signature without options', (done) ->
        mockMethod.withArgs('/foo', null).yields null, ['bar']
        client.getChildren '/foo', (err) ->
          mock.verify()
          done()

      it 'can create the root path with createPathIfNotExists', (done) ->
        mockMethod.withArgs('/foo', null).yields null, ['bar']
        mock.expects('mkdir').once().withArgs('/foo').yields null
        client.getChildren '/foo', createPathIfNotExists: true, (err) ->
          mock.verify()
          done()

      it 'does not create the root path without createPathIfNotExists', (done) ->
        mockMethod.withArgs('/foo', null).yields null, ['bar']
        mock.expects('mkdir').never()
        client.getChildren '/foo', (err) ->
          mock.verify()
          done()

      it 'can retrieve the child values with getChildData', (done) ->
        mockMethod.withArgs('/foo', null).yields null, ['foo', 'bar']
        mock.expects('joinPath').once().withArgs('/foo', 'foo').returns '/foo/foo'
        mock.expects('joinPath').once().withArgs('/foo', 'bar').returns '/foo/bar'
        mock.expects('get').once().withArgs('/foo/foo').yields null, {}, "foo-result"
        mock.expects('get').once().withArgs('/foo/bar').yields null, {}, "bar-result"
        client.getChildren '/foo', getChildData: true, (err, res) ->
          should.not.exist err
          res.should.eql foo: "foo-result", bar: "bar-result"
          mock.verify()
          done()

      it 'does not retrieve the child values without getChildData', (done) ->
        mockMethod.withArgs('/foo', null).yields null, ['foo', 'bar']
        client.getChildren '/foo', (err, res) ->
          res.should.eql ['foo', 'bar']
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
