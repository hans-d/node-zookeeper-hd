zookeeper-hd
============

Higher level (normalized) client for Zookeeper.

Uses https://github.com/yfinkelstein/node-zookeeper as underlying client.

API
---

### SimpleClient

Quick overview:
- normalize function names ( get vs a_get )
- normalize callback signatures to common nodejs callback structures (error, results)
- exists returns true/false via callback (error, exists, stats)
- except for noted above, tries to follow the underlying zookeeper client signature

Methods
- create (zkPath, value, flags, onReady)
- exists: (zkPath, watch, onData)
- get: (zkPath, watch, onData)
- getChildren: (zkPath, watch, onData)
- mkdir: (zkPath, onReady)
- set: (zkPath, value, version, onReady)


### PlusClient

Quick overview
- wraps SimpleClients
- added: createOrUpdate
- added: createPathIfNotExist
- redefines the signatures of the SimpleClient methods, using an optional options argument

Added methods:
- createOrUpdate: (zkPath, value, options, onReady, extraArg)
    Options: { flags, watch }
- createPathIfNotExist: (zkPath, options, onReady)

Redefined methods from SimpleClient
- create: (zkPath, value, options, onReady)
- exists: (zkPath, options, onData)
- get: (zkPath, options, onData)
- getChildren: (zkPath, options, onData)
- mkdir: (zkPath, options, onReady)
- set: (zkPath, value, version, options, onReady)



Various
-------

MIT Licensed

Source is in coffee script, but is delivered as plain .js

Semantic Versioning

Grunt is used for build/development automation

