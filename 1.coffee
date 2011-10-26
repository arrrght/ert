require('zappa') ->
  @use 'bodyParser', 'methodOverride', @app.router, 'static'
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @enable 'serve sammy', 'minify', 'serve jquery'

  global.Mongoose = require 'mongoose'
  Mongoose.connect 'mongodb://localhost/foo2'

  # Schemas
  Doc2Schema = new Mongoose.Schema { touch: Date, org: Mongoose.Schema.ObjectId, author: Mongoose.Schema.ObjectId, txt: String, dat: Date }
  Ppl2Schema = new Mongoose.Schema { touch: Date, org: Mongoose.Schema.ObjectId, name: String, post: String, tel: String }
  Org2Schema = new Mongoose.Schema { touch: Date, name: String, addr: String }

  Org2 = Mongoose.model 'org2', Org2Schema
  Doc2 = Mongoose.model 'doc2', Doc2Schema
  Ppl2 = Mongoose.model 'ppl2', Ppl2Schema

  DocSchema = new Mongoose.Schema { author: String, date: String, txt: String, dat: Date }
  PplSchema = new Mongoose.Schema { name: String, post: String, tel: String }
  OrgSchema = new Mongoose.Schema { name: String, addr: String, ppls: [PplSchema], docs: [ DocSchema ] }

  Org = Mongoose.model 'org', OrgSchema
  Doc = Mongoose.model 'doc', DocSchema
  Ppl = Mongoose.model 'doc', PplSchema

  @get '/': ->
    @user = plan: 'staff'
    @render 'index', { @user }

  @client '/index.js': ->
    # find Org by name
    
    buttonsOn = (stage) ->
      st =
        root: 'no .ppls, no #btn-rm-org, no #btn-add-tel, no #btn-rm-ppl'
        org: '#btn-add-tel, #btn-rm-org, no #btn-rm-ppl'
        tel: 'no #btnOtherPpl, no #btn-rm-org, no #btn-add-tel, #btn-rm-ppl'
        telFor: 'no #btn-rm-org, no #btn-add-tel, #btn-rm-ppl'
      st[stage].split(', ').map (b) ->
        m = b.match '^no\ (.+)$'
        if m isnt null then hide m[1] else show b

    clean = ->
      content = $ '.content'
      ppl = $ '.ppls ul'
      content.empty()
      ppl.empty()

    showDate = (d) ->
      d = new Date(d) if d
      d = new Date
      mo = 'января февраля марта апреля мая июня июля августа сентября октября декабря'.split ' '
      da = 'воскресенье понедельник вторник среда четверг пятница суббота'.split ' '
      "#{da[d.getDay()]}, #{d.getDate()} #{mo[d.getMonth()]} #{d.getFullYear()} г."

    findOrg = (name) ->
      fnd = $('#smart').val()
      $.getJSON "/findOrg/#{fnd}", (data) ->
        $('.sidebar .orgs').empty()
        data.map (d) ->
          $('.sidebar .orgs').append "<li><a href='#/org/#{d._id}'>#{d.name}</a></li>"

    # Helpers
    blockTel = (params) -> [
      "<div class='well tel phone-form'>"
      "<h4>Телефонный разговор</h2>"
      "<blockquote>"
        "<div class='form-stacked'>"
          "<textarea name='txtArea' class='span16' rows='10'/>"
          "<div class='inline-inputs'>"
            "<span>Должность:</span><input name='post' class='span3'/>"
            "<span>ФИО:</span><input name='who' class='span6'/>"
            "<span>Телефон:</span><input name='tel' class='span4'/>"
          "</div"
        "</div>"
        "<small>Тарас Атаманкин</small>"
        "<span class='pull-right'>"
          "<a class='btn info' id='btnOtherPpl'>Другой человек?</a>"
          "<a href='/#/org/#{params.id}' class='btn danger'>Отмена</a>"
          "<a href='/#/org/#{params.id}/newTelOk' class='btn success'>OK</a>"
        "</span>"
        "</blockquote>"
      "</div>"
    ].join ''

    # Org head
    blockOrgHead = (params) -> [
      "<h2>#{params.name}</h2>"
      "<span id='btnPanel'>"
      "</span>"
    ].join ''
    
    # Org body
    blockOrgBody = (params) -> [
      "<div class='well tel'><blockquote>"
        "<p>#{params.txt.replace /\n/g, '<br/>'}</p>"
        "<small>"
        if params.dat then showDate(params.dat) else params.date
        ", #{params.who}" if params.who
        " [ #{params.tel} ]</small>" if params.tel
      "</blockquote></div>"
    ].join ''

    # In Org view -> ppl
    blockOrgPpl = (params, orgId) -> [
      "<li>"
      "<a href='/#/org/#{orgId}/newTel/ppl/#{params._id}'>"
      "#{params.name}"
      " <span class='label'>#{params.post}</label>" if params.post
      "</a></li>"
    ].join ''

    ## getOrg with filllout
    getAndFillOrg = (id, callback) ->
      content = $ '.content'
      ppl = $ '.ppls ul'
      $.getJSON "/getOrgInfo/#{id}", (data) ->
        document.o = data
        content.empty()
        console.log data.org.name
        content.append blockOrgHead data.org
        data.docs.reverse().map (d) -> content.append blockOrgBody d
        # map Ppl
        ppl.replaceWith '<ul>' + ((data.ppls.map (d) -> blockOrgPpl d, id).join '') + '</ul>'
        if data.ppls.length > 0 then show('.ppls') else hide('.ppls')
        callback() if callback

    # JQuery helpers
    show = (prm...) -> prm.map (p) -> $(p).show()
    hide = (prm...) -> prm.map (p) -> $(p).hide()

    # Routes (sammy)
    # Org view
    @get '#/org/:id': (ctx) ->
      buttonsOn 'org'
      getAndFillOrg @params.id

    @get '#/org/:id/newTel/ppl/:ppl': (ctx) ->
      buttonsOn 'telFor'
      unless document.o
        getAndFillOrg @params.id, -> ctx.redirect ctx.sammy_context.path + '?R' # redirect to self
        return false

      found = {}
      document.o.ppls.map (p) -> found = p if p._id is ctx.params.ppl
      if found
        content = $ '#btnPanel'
        content = $ '.content .phone-form' unless content.length
        block = $(blockTel ctx.params)
        block.find('input[name=who]').val(found.name)
        block.find('input[name=tel]').val(found.tel)
        block.find('input[name=post]').val(found.post)
        block.attr 'pplID', found._id
        block.replaceAll content
        $('#btnOtherPpl').click btnOtherPplPressed


    btnOtherPplPressed = (e) ->
      if $('.content .phone-form').attr('pplOther') is 'true'
        $('.content .phone-form').attr 'pplOther', false
        $('.content .phone-form #btnOtherPpl').text('Другой человек?')
      else
        $('.content .phone-form').attr 'pplOther', true
        $('.content .phone-form #btnOtherPpl').text('Другой человек ✓')

    @get '#/newOrg': ->
      $.post '/newOrg', { name: $('#smart').val() }, (data) -> findOrg()

    @get '#/org/:id/newTel': (ctx) ->
      unless document.o
        getAndFillOrg @params.id, -> ctx.redirect ctx.sammy_context.path + '?R' # redirect to self
        return false
      content = $ '#btnPanel'
      $(blockTel @params).replaceAll content
      $('#btnOtherPpl').click btnOtherPplPressed
      buttonsOn 'tel'

    @get '#/org/:id/newTelOk': (ctx) ->
      buttonsOn 'tel'
      block = $ '.content .phone-form'

      $.post '/newTel',
        other: block.attr 'pplOther'
        pplID: block.attr 'pplID'
        txt: block.find('textarea[name=txtArea]').val()
        who: block.find('input[name=who]').val()
        tel: block.find('input[name=tel]').val()
        post: block.find('input[name=post]').val()
        org: @params.id
      , (data) ->
        ctx.redirect "#/org/#{ctx.params.id}"

    @get '/#/': ->
      buttonsOn 'root'
      content = $ '.content'
      $.getJSON "/root", (data) ->
        content.empty()
        content.append '<h2>Последние действия</h2>'
        data.map (d) ->
          txt = d.doc.txt.replace /\n/g, '<br/>'
          content.append [
            "<div class='well'>"
              "<h4>"
                "<a href='/#/org/#{d.org._id}'>#{d.org.name}</a>"
                #"<a href='#' class='btn xsmall success'>Далее</a>"
              "</h4>"
              "<blockquote>"
                "<p>#{txt}</p>"
                "<small>"
                  "#{showDate(d.doc.dat)}, Тарас Атаманкин, телефонный звонок: #{d.doc.who}, по телефону #{d.doc.tel}"
                "</small>"
              "</blockquote>"
            "</div>"
          ].join ''

      console.log '***', @
      buttonsOn 'root'
      $.get '/root', (data) ->
        console.log 'ROOT', data

    $(document).ready ->

      $('.container-fluid:first').append "<small class='date'>#{showDate()}</small>"
      findOrg()

      $('#btn-add-tel').click ->
        try id = document.location.hash.match('^#/org/(\\w+)$').pop()
        document.location = "/#/org/#{id}/newTel" if id

      # Удаление человека
      $('#btn-rm-ppl').click ->
        try id = document.location.hash.match('^#/org/(\\w+)/newTel/ppl/(\\w+)$')
        if id and confirm 'Уверен?'
          $.post '/rmPpl', { ppl: id[2], org: id[1] }, -> document.location = "/#/org/#{id[1]}"

      # Удаление организации
      $('#btn-rm-org').click ->
        try id = document.location.hash.match('^#/org/(\\w+)$').pop()
        if id and confirm 'Уверен?'
          $.post '/rmOrg', { id: id }, (data) ->
            hide '#btn-rm-org'
            $('#smart').val ''
            clean() # TODO: remove that when root is ready
            findOrg()
            document.location = '/#/'

      $('#btnOK').click ->
        console.log 'HI'

      $('input[id=smart]').change (e) -> findOrg()
      $('#smart-clear').click (e) ->
        $('#smart').val ''
        findOrg()
  # End-of-client

  # Helper for parallel fetch
  doIt = (funs, callback ) ->
    aggr = {}
    cnt = Object.keys(funs).length
    for key, val of funs # Kill me gently
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
      docs: Doc2.find({ org: @params.id })
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
    
