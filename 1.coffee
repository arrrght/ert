require('zappa') ->
  [global.Mongoose, fs, vm, coffee] = [require('mongoose'), require('fs'), require('vm'), require('coffee-script')]
  global.Ext = require './h2e4'
  Mongoose.connect 'mongodb://localhost/foo'

  @use 'bodyParser', 'methodOverride', @app.router
  @enable 'minify'
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @use @express.compiler({ src: "#{__dirname}/public", enable: ['coffeescript'], minify: yes }), 'static'

  # TODO: auto populate that
  @client '/direct/api.js': ->
    Ext.app.REMOTING_API =
      enableBuffer: 100
      type: 'remoting'
      url: '/direct/entry'
      actions:
        Org: [
          { name: 'find', len: 1 }
          { name: 'getText', len: 1 }
          { name: 'setText', len: 1 }
          { name: 'new', len: 1 }
        ]
    Ext.Direct.addProvider Ext.app.REMOTING_API

  #@post '/direct/entry': -> Ext.entry @request, @response, @next
  @post '/direct/entry': Ext.entry

  # Parse model Org
  Ext.evalFile 'model/Org'

  Ext.endpoint 'Org.find', (r) ->
    txt = 'ГОК'
    try txt = r.data.filter[0].value or 'ГОК'
    console.log r.data
    Ext.Org
      .find({ name: new RegExp txt, 'i' })
      .sort('name', 'asc')
      .execFind (err, docs) ->
        r.success docs or [{ name: 'NONE' }]

  Ext.endpoint 'Org.getText', (r) ->
    return r.failure 'Can\'t find ID in your params' unless r.data.id
    console.log r.data.id
    Ext.Org.findById r.data.id, (err, doc) ->
      if err or !doc
        r.failure { message: 'Can\'t find that.' }
      else
        console.log doc
        r.success { doc: doc.txt }

  Ext.endpoint 'Org.setText', (r) ->
    console.log r.data
    return r.failure 'PRM' unless r.data.id
    Ext.Org.findById r.data.id, (err, doc) ->
      if err or !doc
        r.failure { message: 'Can\'t find that.' }
      else
        doc.txt = r.data.txt
        doc.save (err) ->
          if err
            r.failure { message: '???', err: err }
          else
            r.success { txt: doc.txt }

   Ext.endpoint 'Org.new', (r) ->
    console.log r.data
    return r.failure 'Params' unless r.data.name
    r.success { yea: true }
