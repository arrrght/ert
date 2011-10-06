require('zappa') ->
  @Mongoose = require 'mongoose'
  @Mongoose.connect 'mongodb://localhost/foo'
  @use 'bodyParser', 'methodOverride', @app.router
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @use @express.compiler({ src: "#{__dirname}/public", enable: ['coffeescript'] }), 'static'


#  app.get '/view/*', (req, res) ->
#    res.header 'Content-type', 'text/javascript'
#    res.render req.url+'.coffee'
#    #res.partial "#{req.url}.coffee"
#  #include 'view/index.js'

  @client '/direct/api.js': ->
    Ext.app.REMOTING_API =
      enableBuffer: 100
      type: 'remoting'
      url: '/direct/entry'
      actions:
        Org: [
          { name: 'new', len: 1 }
          { name: 'find', len: 1 }
        ]
    Ext.Direct.addProvider Ext.app.REMOTING_API


  Ext =  { 'require': {} }
  require __dirname + '/public/app/model/Org.coffee'

  #Org = require __dirname + '/public/app/model/Org.coffee'

  #include 'schemes'
  @include 'entry'
