// This file has been generated from coffee source files

var Scarlet, SimpleClient, client, scarlet, scarletLogger;

Scarlet = require('scarlet');

scarlet = new Scarlet('scarlet-contrib-logger');

scarletLogger = scarlet.plugins.logger;

SimpleClient = require('../src/lib/SimpleClient');

client = new SimpleClient({
  connect: "localhost:2181",
  timeout: 200,
  debug_level: 2,
  host_order_deterministic: false
});

client.connect(function(err) {
  console.log("error?: " + err);
  client.getChildren('/', null, function(err, children) {
    console.log('result: ', children);
  });
});

/*
//@ sourceMappingURL=indirect_logging.js.map
*/