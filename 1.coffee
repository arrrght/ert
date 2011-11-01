require('zappa') ->
  @use 'bodyParser', 'methodOverride', @app.router, 'static'
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @enable 'serve sammy', 'minify', 'serve jquery'

  global.Mongoose = require 'mongoose'
  Mongoose.connect 'mongodb://localhost/foo2'

  # Schemas
  { Org2, Doc2, Ppl2 } = require './models'

  @get '/': ->
    @user = plan: 'staff'
    @render 'index', { @user }

  @include 'client'

  # Helper for parallel fetch
  doIt = (funs, callback ) ->
    aggr = {}
    cnt = Object.keys(funs).length
    for key, val of funs
      ((key,val) -> val.execFind (err, res) =>
        if key[0] is '$' then aggr[key.substring 1] = res.pop() else aggr[key]=res
        callback(aggr) if --cnt is 0
      )(key, val)

  # Server-side
  @get '/root', ->
    ret = []
    Doc2
      .find()
      .desc('dat')
      .limit(25)
      .populate('author')
      .execFind (err, result) =>
        cnt = result.length
        result.map (doc) =>
          Org2.findById doc.org, (err, res) =>
            ret.push { doc: doc , org: res }
            @send ret if --cnt == 0

  @post '/rmPpl', ->
    return { err: 'nothing' } unless @body.ppl
    Ppl2.remove { _id: @body.ppl }, (err, res) =>
      @send { ok: yes }

  @post '/rmOrg', ->
    return { err: 'nothing to do' } unless @body.id
    Org2.findById @body.id, (err, res) =>
      @send { err: 'Can\'t find that' } if err or not res
      res.remove (err) =>
        if err then @send err: err else @send { ok: yes }
    
  @post '/newOrg', ->
    return { err: 'nothing to do' } unless @body.name
    org = new Org2 { touch: new Date(), name: @body.name }
    org.save (ok) => @send { ok: yes }

  @post '/newTel', ->
    return { err: 'nothing to do' } unless @body.org
    if @body.txt
      (new Doc2 { touch: new Date(), org: @body.org, dat: new Date, txt: @body.txt, who: @body.who, tel: @body.tel  }).save() # Don't care
    if @body.pplID and @body.other isnt 'true'
      Ppl2.update { _id: @body.pplID }, { touch: new Date(), name: @body.who, tel: @body.tel, post: @body.post }, (err, res) =>
        # Don't care
    else # New ppl
      (new Ppl2({ touch: new Date(), org: @body.org, name: @body.who, tel: @body.tel, post: @body.post })).save() # Don't care
    @send { ok : yes } # Always yes

  @get '/getOrgInfo/:id?': ->
    doIt
      $org: Org2.findById(@params.id)
      docs: Doc2.find({ org: @params.id }).sort('dat','desc').populate('author')
      ppls: Ppl2.find({ org: @params.id })
    , (res) => @send res

  @get '/findOrg/:name?': ->
    fnd = @params.name
    Org2
      .find({ name: new RegExp fnd, 'i' })
      .sort('name', 'asc')
      .limit(25)
      .execFind (err, result) =>
        @send result

  @view 'index': ->
    # comment
    
