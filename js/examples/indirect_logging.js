// This file has been generated from coffee source files

/*
  this is an example how to get logging on the simple client
  using a library like scarletjs
*/

var Scarlet, SimpleClient, client, scarlet, scarletLogger;

Scarlet = require('scarlet');

scarlet = new Scarlet('scarlet-contrib-logger');

scarletLogger = scarlet.plugins.logger;

SimpleClient = require('../src/lib/SimpleClient');

client = new SimpleClient({
  connect: "localhost:2181"
});

scarletLogger.bindTo(client);

client.connect(function(err) {
  console.log("error?: " + err);
  client.getChildren('/', null, function(err, children) {
    console.log('result: ', children);
  });
});

/*
//@ sourceMappingURL=indirect_logging.js.map
*/