node-zookeeper-hd
=================

*Please use zookeeper-hd instead of this version*
Name has changed, this will refer to the latest zookeeper-hd version.


Higher level (normalized) client for Zookeeper.

SimpleClient:
- normalize function names ( get vs a_get )
- normalize callback signatures to common nodejs callback structures (error, results)
- exists returns true/false

PlusClient:
- createOrUpdate
- createPathIfNotExist

Various
-------

MIT Licensed

Source is in coffee script, but is delivered as plain .js

Semantic Versioning

Grunt is used for automation
