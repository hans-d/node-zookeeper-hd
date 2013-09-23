SimpleClient = require './SimpleClient'

module.exports = class PlusClient extends SimpleClient

  createOrUpdate: (zkPath, value, flags, watch, onReady) ->
    @log.info "setOrCreate #{value} @ #{zkPath}"
    @exists zkPath, watch, (err, exists, stat) =>
      return onReady(err) if err
      return @set zkPath, value, stat.version, onReady if exists
      @create zkPath, value, flags, onReady

  createPathIfNotExist: (zkPath, onReady) ->
    @log.info "createPathIfNotExists #{zkPath}"
    @mkdir zkPath, onReady
