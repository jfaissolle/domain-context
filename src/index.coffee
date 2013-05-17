domain = require 'domain'

exports.init = (init, domain = require('domain').active) ->
  throw new Error('no active domain') unless domain?
  domain.__context__ = init()

exports.cleanup = (cleanup, domain = require('domain').active) ->
  throw new Error('no active domain') unless domain?
  cleanup(domain.__context__) if cleanup? and domain.__context__?
  domain.__context__ = null

exports.onError = (onError, context = null, domain = require('domain').active) ->
  onError(context or domain.__context__) if onError?
  domain.__context__ = null

exports.get = (key, domain = require('domain').active) ->
  throw new Error('no active domain') unless domain?
  domain.__context__[key]

exports.middleware = (init, cleanup) ->
  (req, res, next) ->
    {init, cleanup} = init if typeof init != 'function'
    domain = require('domain').active
    exports.init(init, domain)
    res.on 'finish', -> exports.cleanup(cleanup, domain)
    req.__context__ = domain.__context__
    next()

exports.middlewareOnError = (onError) ->
  (err, req, res, next) ->
    {onError} = onError if typeof onError != 'function'
    exports.onError(onError, req.__context__)
    req.__context__ = null
    next(err)
