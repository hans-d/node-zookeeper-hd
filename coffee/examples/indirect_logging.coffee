###
  this is an example how to get logging on the simple client
  using a library like scarletjs
###

Scarlet = require 'scarlet'
scarlet = new Scarlet 'scarlet-contrib-logger'
scarletLogger = scarlet.plugins.logger

SimpleClient = require '../src/lib/SimpleClient'

client = new SimpleClient connect: "localhost:2181"

scarletLogger.bindTo client

client.connect (err) ->
  console.log "error?: #{err}"
  client.getChildren '/', null, (err, children) ->
    console.log 'result: ', children
    return
  return

