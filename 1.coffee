require('zappa') ->
  @use 'bodyParser', 'methodOverride', @app.router, 'static'
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @enable 'serve sammy', 'minify', 'serve jquery'

  global.Mongoose = require 'mongoose'
  Mongoose.connect 'mongodb://localhost/foo2'

  # Schemas
  DocSchema = new Mongoose.Schema { author: String, date: String, txt: String }
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
        root: 'no rm-org, no add-tel, no rm-ppl'
        org: 'add-tel, rm-org, no rm-ppl'
        tel: 'no rm-org, no add-tel, rm-ppl'
      st[stage].split(', ').map (b) ->
        m = b.match '^no\ (.+)$'
        if m isnt null then hide "#btn-#{m[1]}" else show "#btn-#{b}"

    clean = ->
      content = $ '.content'
      ppl = $ '.ppls ul'
      content.empty()
      ppl.empty()

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
          #"<a href='/#/org/#{params.id}/rmPpl' class='btn danger' id='btnRmPpl'>Удалить человека</a>"
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
        "<p>#{params.txt}</p>"
        "<small>#{params.date}"
        ", #{params.who}" if params.who
        "[ #{params.tel} ]</small>" if params.tel
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
        content.append blockOrgHead data
        data.docs.reverse().map (d) -> content.append blockOrgBody d
        # map Ppl
        ppl.replaceWith '<ul>' + ((data.ppls.map (d) -> blockOrgPpl d, id).join '') + '</ul>'
        if data.ppls.length > 0 then show('.ppls') else hide('.ppls')
        callback() if callback

    # JQuery helpers
    show = (prm...) -> prm.map (p) -> if $.isFunction(p) then p.apply(@) else $(p).show()
    hide = (prm...) -> prm.map (p) -> if $.isFunction(p) then p.apply(@) else $(p).hide()

    # Routes (sammy)
    # Org view
    @get '#/org/:id': (ctx) ->
      buttonsOn 'org'
      show '#btn-rm-org'
      getAndFillOrg @params.id

    @get '#/org/:id/newTel/ppl/:ppl': (ctx) ->
      buttonsOn 'tel'
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
      buttonsOn 'tel'
      content = $ '#btnPanel'
      $(blockTel @params).replaceAll content
      $('#btnOtherPpl').click btnOtherPplPressed

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

    $(document).ready ->
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

  # Server-side
  @post '/rmPpl', ->
    return { err: 'nothing' } unless @body.ppl
    that = @
    Org.findById @body.org, (err, res) ->
      res.ppls.map (p) ->
        if p._id.toString() is that.body.ppl
          p.remove (err) ->
            res.save()
            unless err then that.send { ok: yes } else that.send { err: err }

  @post '/rmOrg', ->
    return { err: 'nothing to do' } unless @body.id
    that = @
    Org.findById @body.id, (err, res) ->
      that.send { err: 'Can\'t find that' } if err or not res
      res.remove (err) ->
        if err then that.send err: err else that.send { ok: yes }
    
  @post '/newOrg', ->
    return { err: 'nothing to do' } unless @body.name
    that = @
    org = new Org { name: @body.name }
    org.save (ok) ->
      that.send { ok: yes }

  @post '/newTel', ->
    return @send { err: 'nothing to do' } unless @body.org
    that = @
    Org.findById @body.org, (err, res) ->
      that.send { err: 'Can not find Org' } if err or not res
      if that.body.txt
        doc = new Doc { date: new Date, txt: that.body.txt, who: that.body.who, tel: that.body.tel  }
        res.docs.push doc
      if that.body.pplID and that.body.other isnt 'true'
        console.log 'Got pplID', that.body.pplID
        res.ppls.map (p) ->
          if p._id.toString() is that.body.pplID
            console.log that.body
            p.name = that.body.who
            p.tel = that.body.tel
            p.post = that.body.post
      else if that.body.who
        ppl = new Ppl { name: that.body.who, tel: that.body.tel, post: that.body.post }
        res.ppls.push ppl
      res.save (err) ->
        that.send { ok: yes }

  @get '/getOrgInfo/:id?': ->
    that = @
    Org.findById @params.id, (err, res) ->
      that.send res

  @get '/findOrg/:name?': ->
    fnd = @params.name
    that = @
    Org
      .find({ name: new RegExp fnd, 'i' })
      .exclude('docs', 'ppls')
      .sort('name', 'asc')
      .limit(10)
      .execFind (err, result) ->
        that.send result

  @get '/new': ->
    # generate newId and redirect to new page
    @redirect '#/org/123'

  @get '/org/:id': ->
    # Render start's page
    @render 'org'

  @view 'index': ->
    # comment
    
