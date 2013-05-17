# connect-reqcontext

Middleware for Connect which provides globally accessible request context with
lifecycle hooks.

This middleware can only be used inside an active domain, use
[connect-domain][].

    var connectDomain = require('connect-domain');
    var connectReqContext = require('connect-reqcontext');

    ...
    app.use(connectDomain());
    app.use(connectReqContext.requestContext(function() {
      // return context you want to attach to the request
      return {
        db: new pg.Client(...)
      }
    }, function (context) {
      // this callback will be called when response is finished
      // if custom callback on error is provided (see below) then this callback
      // will only be called on successful circumstances
      context.db.query('commit');
      context.db.end();
    });
    ...
    // middleware below is optional if you want custom cleanup on error
    app.use(connectReqContext.requestContextOnError(function(context) {
      context.db.query('rollback');
      context.db.end();
    });
    ...

    // in another file, maybe in models.js or something like this
    // you can access db connection without having access to a request object
    var connectReqContext = require('connect-reqcontext');

    function getUserById(id, cb) {
      connectReqContext.get('db').query("select ...", cb);
    }


[connect-domain]: https://github.com/baryshev/connect-domain
