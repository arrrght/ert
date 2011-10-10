require('zappa') ->
  [global.Mongoose, fs, vm, coffee] = [require('mongoose'), require('fs'), require('vm'), require('coffee-script')]
  global.Ext = require './h2e4'
  Mongoose.connect 'mongodb://localhost/foo2'

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
          { name: 'rm', len: 1 }
        ]
    Ext.Direct.addProvider Ext.app.REMOTING_API

  @post '/direct/entry': Ext.entry

  Ext.evalFile 'model/Org'

  Ext.endpoint 'Org.rm', (r) ->
    return failure { message: 'Can\'t get a ID '} unless r.data.id
    Ext.Org.findById r.data.id, (err, res) ->
      return failure { message: 'Can\'t find that'} if err or not res
      res.remove (err) ->
        if err then r.failure err else r.success { message: 'OK' }

  Ext.endpoint 'Org.find', (r) ->
    #txt = 'ГОК'
    txt = ''
    try txt = r.data.filter[0].value or txt
    Ext.Org
      .find({ name: new RegExp txt, 'i' })
      .sort('name', 'asc')
      .execFind (err, docs) ->
        r.success docs or [{ name: 'NONE' }]

  Ext.endpoint 'Org.getText', (r) ->
    return r.failure 'Can\'t find ID in your params' unless r.data.id
    Ext.Org.findById r.data.id, (err, doc) ->
      if err or !doc
        r.failure { message: 'Can\'t find that.' }
      else
        console.log doc
        r.success { docs: doc.docs }

  Ext.endpoint 'Org.setText', (r) ->
    return r.failure 'PRM' unless r.data.id
    doc = new Ext.Doc { date: new Date, txt: r.data.txt }
    Ext.Org.findById r.data.id, (err, res) ->
      if err or !res
        r.failure { message: 'Can\'t find that.' }
      else
        res.docs.push doc
        res.save (err) ->
          if err
            r.failure { message: '???', err: err }
          else
            r.success { docs: res.docs }

   Ext.endpoint 'Org.new', (r) ->
    name = r.data.name
    return r.failure { message: 'Wrong name' } unless r.data.name
    org = new Ext.Org { name: name }
    org.save (ok) ->
      r.success { id: ok }
