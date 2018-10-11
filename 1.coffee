require('zappa') ->
  [global.Mongoose, fs, vm, coffee] = [require('mongoose'), require('fs'), require('vm'), require('coffee-script')]
  global.Ext = require './h2e4'
  Mongoose.connect 'mongodb://localhost/foo2'

  @use 'bodyParser', 'methodOverride', @app.router
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @use @express.compiler({ src: "#{__dirname}/public", enable: ['coffeescript'], minify: yes }), 'static'

  @get '/direct/api.js': Ext.api
  @post '/direct/entry': Ext.entry

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

###require('zappajs').run 3333, ->
###  @set views: "#{__dirname}/views"
###  @use 'bodyParser', 'methodOverride', @app.router, 'static'
###  @use errorHandler: { dumpExceptions: on, showStack: on }
###  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
###  @enable 'serve sammy', 'minify', 'serve jquery'
###
###  # TODO Whay is so globally's?
###  global.Mongoose = require 'mongoose'
###  Mongoose.connect 'mongodb://localhost/foo2'
###  global._ = require 'underscore'
###
###  # Client-side script with sammy, jquery and Twitter bootstrap css
###  @include 'client'
###
###  # Schemas
###  { Org2, Doc2, Ppl2 } = require './models'
###
###  # TODO login page
###  #
### 
###  # Get default Ppl (when holes in db)
###  DefPpl = {}
###  Ppl2.findById '4eaffc0436b57c880f048d13', (err,doc) =>
###    unless err then DefPpl = doc else console.log 'Can not find def Ppl'
###
###  # Show root page
###  @get '/': ->
###    @user = plan: 'staff'
###    @render 'index', { @user }
###
###  # Helper for parallel fetch
###  # Return hash
###  doIt = (funs, callback ) ->
###    aggr = {}
###    cnt = Object.keys(funs).length
###    for key, val of funs
###      ((key,val) -> val.execFind (err, res) =>
###        # Return single value if key starts with $
###        if key[0] is '$' then aggr[key.substring 1] = res.pop() else aggr[key]=res
###        callback(aggr) if --cnt is 0
###      )(key, val)
###
###  # Server-side
###  # Show root page with last conversation
###  @get '/root', ->
###    ret = []
###    Doc2.find().sort({ dat: 'desc'}).limit(25).populate('author').execFind (err, result) =>
###      # TODO change to populate?
###      cnt = result.length
###      result.map (doc) =>
###        Org2.findById doc.org, (err, res) =>
###          doc.author = DefPpl unless doc.author
###          ret.push { doc: doc , org: res }
###          @send ret if --cnt == 0
###
###  # Remove ppl
###  @post '/rmPpl', ->
###    return { err: 'nothing' } unless @body.ppl
###    Ppl2.remove { _id: @body.ppl }, (err, res) =>
###      @send { ok: yes }
###
###  # Remove org
###  @post '/rmOrg', ->
###    return { err: 'nothing to do' } unless @body.id
###    Org2.findById @body.id, (err, res) =>
###      @send { err: 'Can\'t find that' } if err or not res
###      res.remove (err) =>
###        if err then @send err: err else @send { ok: yes }
###    
###  # New org
###  @post '/newOrg', ->
###    return { err: 'nothing to do' } unless @body.name
###    org = new Org2 { touch: new Date(), name: @body.name }
###    org.save (ok) => @send { ok: yes }
###
###  # TODO Change org info (tel, www, mail..)
###
###  # New conversation with new/update ppl or just new/update ppl
###  @post '/newTel', ->
###    return { err: 'nothing to do' } unless @body.org
###    if @body.txt
###      # Doc create if txt
###      (new Doc2 { touch: new Date(), org: @body.org, dat: new Date, txt: @body.txt, who: @body.who, tel: @body.tel  }).save() # Don't care
###    if @body.pplID and @body.other isnt 'true'
###      # Ppl update
###      Ppl2.update { _id: @body.pplID }, { touch: new Date(), name: @body.who, tel: @body.tel, post: @body.post }, (err, res) => # Don't care
###    else
###      # New ppl
###      (new Ppl2({ touch: new Date(), org: @body.org, name: @body.who, tel: @body.tel, post: @body.post })).save() # Don't care
###    @send { ok : yes } # Always yes
###
###  # Get single org by ID
###  # TODO get by name? eq: /getOrgInfo/Алапаевский рудник имени Ленина OR /getOrgInfo/Caterpillar
###  @get '/getOrgInfo/:id?': ->
###    doIt
###      $org: Org2.findById(@params.id)
###      docs: Doc2.find({ org: @params.id }).sort({ 'dat':'desc' }).populate('author')
###      ppls: Ppl2.find({ org: @params.id })
###    , (res) => @send res
###
###  # Find org by name
###  @get '/findOrg/:name?': ->
###    fnd = @params.name
###    console.log "FND: #{fnd}"
###    Org2
###      .find({ name: new RegExp fnd, 'i' })
###      .sort({ name:'asc' })
###      .limit(25)
###      .execFind (err, result) =>
###        @send result
