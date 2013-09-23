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
    mockery.registerAllowables [ './SimpleClient', 'path']      # allowed require-s
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
      stub = client.exists = sinon.stub()

    afterEach ->
      client = mock = stub = null

    it 'should update if path exists', (done) ->
      stub.yields null, true, version: 15
      mock.expects('set').once().withArgs('/foo', 'bar', 15).yields null, 'foobar'
      mock.expects('create').never()
      client.createOrUpdate '/foo', 'bar', 1, 2, (err, res) ->
        should.not.exist err
        res.should.equal 'foobar'
        mock.verify()
        stub.calledOnce.should.equal true
        done()

    it 'should create if path does not exist', (done) ->
      stub.yields null, false
      mock.expects('create').once().withArgs('/foo', 'bar', 1).yields null, 'foobar'
      mock.expects('set').never()
      client.createOrUpdate '/foo', 'bar', 1, 2, (err, res) ->
        should.not.exist err
        res.should.equal 'foobar'
        mock.verify()
        stub.calledOnce.should.equal true
        done()

  describe '#createPathIfNotExist', ->

    beforeEach ->
      client = new PlusClient root: '/some/Root'
      mock = sinon.mock client

    afterEach ->
      client = mock = stub = null

    it 'should always call mkdir', (done) ->
      mock.expects('mkdir').once().withArgs('/foo').yields null, 'foobar'
      client.createPathIfNotExist '/foo', (err, res) ->
        should.not.exist err
        res.should.equal 'foobar'
        mock.verify()
        done()
