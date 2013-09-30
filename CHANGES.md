Changes
=======

Overview of api changes, for details see the commit log.
Uses semantic versioning

0.x
---
- 0.2:
    - PlusClient
        - wraps SimpleClient instead of extending it, remains api compatible
        - added getChildren options:
            - createPathIfNotExists (default: false)
            - getChildData (default: false), only for the last level
            - levels (default: 1), to get childs of childs
        - renamed createPathIfNotExist to createPathIfNotExists (old method redirects)
    - SimpleClient
        - added joinPath (also exposed by PlusClient)
- 0.1:
    - published under zookeeper-hd, instead of node-zookeeper-hd
- 0.0:
    - first published as node-zookeeper-hd
