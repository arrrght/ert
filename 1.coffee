require('zappa') ->
  @use 'bodyParser', 'methodOverride', @app.router, 'static'
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @enable 'serve sammy', 'minify', 'serve jquery'

  @get '/': -> @render 'index'

  @view 'index': ->
    @title = 'PicoChat!'
