should = require 'should'
mockery = require 'mockery'
sinon = require 'sinon'

zookeeperStub = require '../lib/zookeeperStub'

# SimpleClient uses Zookeeper client, here we will use a test double for it.
# (so we can unit test without needing a zookeeper instance)
# Set up for modified require-s is done in #before
#
# simply passes the various data, so very generic fake values are used in the tests

describe 'SimpleClient Class', ->
  # adjusted require
  SimpleClient = null
  # test specific
  clientWithoutRoot = clientWithRoot = stub = null

  before ->
    # control require-d modules
    mockery.enable()
    mockery.registerAllowable '../../src/lib/SimpleClient'        # module under test
    mockery.registerAllowables ['path']                           # allowed require-s
    # replace modules for testing
    mockery.registerMock 'zookeeper', zookeeperStub.Client
    # load module under test, using replaced require-d modules
    SimpleClient = require '../../src/lib/SimpleClient'

  after ->
    mockery.deregisterAll()
    mockery.disable()

  afterEach ->
    clientWithoutRoot = clientWithRoot = stub = null

  describe 'new SimpleClient', ->
    it 'can be created', ->
      client = new SimpleClient()
      client.should.exist
      client.root.should.equal ''

    it 'has a zookeeper client', ->
      client = new SimpleClient()
      client.client.should.be.instanceof zookeeperStub.Client # replaced version
      client.root.should.equal ''

    it 'can have a root', ->
      client = new SimpleClient root: '/some/Root'
      client.client.should.be.instanceof zookeeperStub.Client # replaced version
      client.root.should.equal '/some/Root'


  describe '#fullPath', ->

    beforeEach ->
      clientWithoutRoot = new SimpleClient()
      clientWithRoot = new SimpleClient root: '/some/Root'

    afterEach ->
      clientWithoutRoot = null
      clientWithRoot = null

    it 'returns the same path witout a root', ->
      clientWithoutRoot.fullPath('/somePath').should.equal '/somePath'

    it 'returns a path with root when a root is present', ->
      clientWithRoot.fullPath('/somePath').should.equal '/some/Root/somePath'

    it 'returns 1 slash between root and path when path has no leading slash', ->
      clientWithRoot.fullPath('somePath').should.equal '/some/Root/somePath'

    it 'return the exact path if no root and path is without leading slash', ->
      clientWithoutRoot.fullPath('somePath').should.equal 'somePath'


  describe '#create', ->

    beforeEach ->
      clientWithoutRoot = new SimpleClient()
      clientWithRoot = new SimpleClient root: '/some/Root'
      stub = clientWithoutRoot.client.a_create = sinon.stub()

    afterEach ->
      clientWithoutRoot = clientWithRoot = stub = null

    it 'calls a_create with full path', (done) ->
      mock = sinon.mock clientWithRoot.client
      mock.expects('a_create').once().withArgs('/some/Root/foo', 'bar', 1).yields null
      clientWithRoot.create '/foo', 'bar', 1, ->
        mock.verify()
        done()

    it 'gives normalized result callback on ok', (done) ->
      stub.yields 0, 'foo-error', 'foo-result'
      clientWithoutRoot.create '/foo', 'bar', 1, (err, res) ->
        should.not.exist err
        res.should.equal 'foo-result'
        stub.calledOnce.should.equal true
        done()

    it 'gives normalized error callback on error', (done) ->
      stub.yields 1, 'foo-error', 'foo-result'
      clientWithoutRoot.create '/foo', 'bar', 1, (err, res) ->
        err.should.equal 'foo-error'
        stub.calledOnce.should.equal true
        done()


  describe '#exists', ->

    beforeEach ->
      clientWithoutRoot = new SimpleClient()
      clientWithRoot = new SimpleClient root: '/some/Root'
      stub = clientWithoutRoot.client.a_exists = sinon.stub()

    afterEach ->
      clientWithoutRoot = clientWithRoot = stub = null

    it 'calls a_exists with full path', (done) ->
      mock = sinon.mock clientWithRoot.client
      mock.expects('a_exists').once().withArgs('/some/Root/foo', 1).yields null
      clientWithRoot.exists '/foo', 1, ->
        mock.verify()
        done()

    it 'gives normalized result callback on ok', (done) ->
      stub.yields 0, 'foo-error', 'foo-result'
      clientWithoutRoot.exists '/foo', 1, (err, exists, res) ->
        should.not.exist err
        exists.should.equal true
        res.should.equal 'foo-result'
        stub.calledOnce.should.equal true
        done()

    it 'gives normalized error callback on error', (done) ->
      stub.yields 1, 'foo-error', 'foo-result'
      clientWithoutRoot.exists '/foo', 1, (err, exists, res) ->
        err.should.equal 'foo-error'
        exists.should.equal false
        stub.calledOnce.should.equal true
        done()

    it 'gives normalized result callback on "no node" error', (done) ->
      stub.yields 1, 'no node', 'foo-result'
      clientWithoutRoot.exists '/foo', 1, (err, exists, res) ->
        should.not.exist err
        exists.should.equal false
        should.not.exist res
        stub.calledOnce.should.equal true
        done()


  describe '#get', ->

    beforeEach ->
      clientWithoutRoot = new SimpleClient()
      clientWithRoot = new SimpleClient root: '/some/Root'
      stub = clientWithoutRoot.client.a_get = sinon.stub()

    afterEach ->
      clientWithoutRoot = clientWithRoot = stub = null

    it 'calls a_get with full path', (done) ->
      mock = sinon.mock clientWithRoot.client
      mock.expects('a_get').once().withArgs('/some/Root/foo', 1).yields null
      clientWithRoot.get '/foo', 1, ->
        mock.verify()
        done()

    it 'gives normalized result callback on ok', (done) ->
      stub.yields 0, 'foo-error', 'foo-result'
      clientWithoutRoot.get '/foo', 1, (err, res) ->
        should.not.exist err
        res.should.equal 'foo-result'
        stub.calledOnce.should.equal true
        done()

    it 'gives normalized error callback on error', (done) ->
      stub.yields 1, 'foo-error', 'foo-result'
      clientWithoutRoot.get '/foo', 1, (err, res) ->
        err.should.equal 'foo-error'
        stub.calledOnce.should.equal true
        done()


  describe '#getChildren', ->

    beforeEach ->
      clientWithoutRoot = new SimpleClient()
      clientWithRoot = new SimpleClient root: '/some/Root'
      stub = clientWithoutRoot.client.a_get_children = sinon.stub()

    afterEach ->
      clientWithoutRoot = clientWithRoot = stub = null

    it 'calls a_get_children with full path', (done) ->
      mock = sinon.mock clientWithRoot.client
      mock.expects('a_get_children').once().withArgs('/some/Root/foo', 1).yields null
      clientWithRoot.getChildren '/foo', 1, ->
        mock.verify()
        done()

    it 'gives normalized result callback on ok', (done) ->
      stub.yields 0, 'foo-error', 'foo-result'
      clientWithoutRoot.getChildren '/foo', 1, (err, res) ->
        should.not.exist err
        res.should.equal 'foo-result'
        stub.calledOnce.should.equal true
        done()

    it 'gives normalized error callback on error', (done) ->
      stub.yields 1, 'foo-error', 'foo-result'
      clientWithoutRoot.getChildren '/foo', 1, (err, res) ->
        err.should.equal 'foo-error'
        stub.calledOnce.should.equal true
        done()


  describe '#mkdir', ->

    beforeEach ->
      clientWithoutRoot = new SimpleClient()
      clientWithRoot = new SimpleClient root: '/some/Root'
      stub = clientWithoutRoot.client.mkdirp = sinon.stub()

    afterEach ->
      clientWithoutRoot = clientWithRoot = stub = null

    it 'calls mkdirp with full path', (done) ->
      mock = sinon.mock clientWithRoot.client
      mock.expects('mkdirp').once().withArgs('/some/Root/foo').yields null
      clientWithRoot.mkdir '/foo', ->
        mock.verify()
        done()

    it 'gives normalized result callback on ok', (done) ->
      stub.yields null
      clientWithoutRoot.mkdir '/foo', (err) ->
        should.not.exist err
        stub.calledOnce.should.equal true
        done()

    it 'gives normalized error callback on error', (done) ->
      stub.yields 'foo-error'
      clientWithoutRoot.mkdir '/foo', (err) ->
        err.should.equal 'foo-error'
        stub.calledOnce.should.equal true
        done()


  describe '#set', ->

    beforeEach ->
      clientWithoutRoot = new SimpleClient()
      clientWithRoot = new SimpleClient root: '/some/Root'
      stub = clientWithoutRoot.client.a_set = sinon.stub()

    afterEach ->
      clientWithoutRoot = clientWithRoot = stub = null

    it 'calls a_set with full path', (done) ->
      mock = sinon.mock clientWithRoot.client
      mock.expects('a_set').once().withArgs('/some/Root/foo', 'bar', 1).yields null
      clientWithRoot.set '/foo', 'bar', 1, ->
        mock.verify()
        done()

    it 'gives normalized result callback on ok', (done) ->
      stub.yields 0, 'foo-error', 'foo-result'
      clientWithoutRoot.set '/foo', 'bar', 1, (err, res) ->
        should.not.exist err
        res.should.equal 'foo-result'
        stub.calledOnce.should.equal true
        done()

    it 'gives normalized error callback on error', (done) ->
      stub.yields 1, 'foo-error', 'foo-result'
      clientWithoutRoot.set '/foo', 'bar', 1, (err, res) ->
        err.should.equal 'foo-error'
        stub.calledOnce.should.equal true
        done()
