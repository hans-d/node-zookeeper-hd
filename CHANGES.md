Changes
=======

Overview of api changes, for details see the commit log.
Uses semantic versioning

0.x - Unstable API
---
- 0.5:
    - [so same as 0.4]

- 0.4:
    - Added documentation in source
    - Removed deprecated methods/signature

- 0.3:
    - FakeZookeeper added

- 0.2:
    - PlusClient
        - wraps SimpleClient instead of extending it, remains api compatible
        - added get options:
            - createPathIfNotExists (default: false)
        - added getChildren options:
            - createPathIfNotExists (default: false)
            - getChildData (default: false), only for the last level
            - levels (default: 1), to get childs of childs
        - renamed createPathIfNotExist to createPathIfNotExists (old method redirects)
        - removed logging from library, included example how to enable logging using scarletjs

    - SimpleClient
        - added joinPath (also exposed by PlusClient)
        - error returned {rc, msg } instead of error msg alone
          in case of mkdir rc is null (no code is provided by zookeeper)
        - removed logging from library, included example how to enable logging using scarletjs
        - forgot 'connect' (also now available in PlusClient)

- 0.1:
    - published under zookeeper-hd, instead of node-zookeeper-hd

- 0.0:
    - first published as node-zookeeper-hd
