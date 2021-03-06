# some
require('zappajs') ->
  [global.Mongoose, fs, vm, coffee] = [require('mongoose'), require('fs'), require('vm'), require('coffee-script')]
  global.Ext = require './h2e4'
  Mongoose.connect 'mongodb://localhost/foo2'

  # @use 'bodyParser', 'methodOverride', @app.router
  # @use errorHandler: { dumpExceptions: on, showStack: on }
  # @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  # @use @express.compiler({ src: "#{__dirname}/public", enable: ['coffeescript'], minify: yes }), 'static'

  # @get '/direct/api.js': Ext.api
  # @post '/direct/entry': Ext.entry

  Ext.evalFile 'model/Org'

  Ext.endpoint 'Org.rm', (r) ->
    return failure { message: 'Can\'t get a ID' } unless r.data.id
    Ext.Org.findById r.data.id, (err, res) ->
      return failure { message: 'Can\'t find that' } if err or not res
      res.remove (err) ->
        if err then r.failure err else r.success 'OK'

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
        r.failure 'Can\'t find that.'
      else
        console.log doc
        r.success { docs: doc.docs }

  Ext.endpoint 'Org.setText', (r) ->
    return r.failure 'PRM' unless r.data.id
    doc = new Ext.Doc { date: new Date, txt: r.data.txt }
    Ext.Org.findById r.data.id, (err, res) ->
      if err or !res
        r.failure 'Can\'t find that.'
      else
        res.docs.push doc
        res.save (err) ->
          if err
            r.failure { message: '???', err: err }
          else
            r.success { docs: res.docs }

  Ext.endpoint 'Org.new', (r) ->
   name = r.data.name
   return r.failure 'Wrong name' unless r.data.name
   org = new Ext.Org { name: name }
   org.save (ok) ->
     r.success { id: ok }
