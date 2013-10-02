Scarlet = require 'scarlet'
scarlet = new Scarlet 'scarlet-contrib-logger'
scarletLogger = scarlet.plugins.logger

SimpleClient = require '../src/lib/SimpleClient'

client = new SimpleClient
  connect: "localhost:2181"
  ,timeout: 200
  ,debug_level: 2
  ,host_order_deterministic: false

#scarletLogger.bindTo client

client.connect (err) ->
  console.log "error?: #{err}"
  client.getChildren '/', null, (err, children) ->
    console.log 'result: ', children
    return
  return

