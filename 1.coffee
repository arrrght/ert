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
    
    findOrg = (name) ->
      fnd = $('#smart').val()
      $.getJSON "/findOrg/#{fnd}", (data) ->
        $('.sidebar .orgs').empty()
        data.map (d) ->
          $('.sidebar .orgs').append "<li><a href='#/org/#{d._id}'>#{d.name}</a></li>"

    # helper
    blockTel = (params) -> [
      "<div class='well tel phone-form'>"
      "<h4>Телефонный разговор</h2>"
      "<blockquote>"
        "<div class='form-stacked'>"
          "<textarea name='txtArea' class='span16' rows='10'/>"
          "<div class='inline-inputs'>"
            "<span>С кем:</span><input name='who' class='span9'/>"
            "<span>Телефон:</span><input name='tel' class='span4'/>"
          "</div"
        "</div>"
        "<small>Тарас Атаманкин</small>"
        "<span class='pull-right'>"
          "<a href='/#/org/#{params.id}/rmPpl' class='btn danger' id='btnRmPpl'>Удалить человека</a>"
          "<a class='btn info' id='btnOtherPpl'>Другой человек?</a>"
          "<a href='/#/org/#{params.id}' class='btn danger'>Отмена</a>"
          "<a href='/#/org/#{params.id}/newTelOk' class='btn-ok btn success'>OK</a>"
          #"<a id='btnOK' class='btn-ok btn success'>OK</a>"
        "</span>"
        "</blockquote>"
      "</div>"
    ].join ''

    # Routes (sammy)
    # Org view
    @get '#/org/:id/rmPpl': (ctx) ->
      id = $('.content .phone-form').attr 'pplID'
      $.post '/rmPpl', { ppl: id, org: @params.id }, ->
        ctx.redirect("/#/org/#{ctx.params.id}")

    @get '#/org/:id': (ctx) ->
      content = $ '.content'
      ppl = $ '.ppls ul'
      $.getJSON "/getOrgInfo/#{@params.id}", (data) ->
        document.o = data
        content.empty()
        content.append [
          "<h2>#{data.name}</h2>"
          "<span id='btnPanel'>"
          "<a href='/#/org/#{data._id}/rm' class='btn xsmall danger activePanel'>Удалить компанию</a>"
          "<a href='/#/org/#{data._id}/newTel' class='btn xsmall success activePanel'>Новый телефонный разговор</a>"
          "</span>"
        ].join ''
        # map docs
        data.docs.reverse().map (d) ->
          content.append [
            "<div class='well tel'><blockquote>"
              "<p>#{d.txt}</p>"
              "<small>#{d.date}"
              ", #{d.who}" if d.who
              "[ #{d.tel} ]</small>" if d.tel
            "</blockquote></div>"
          ].join ''
        # map Ppl
        ppl.empty()
        data.ppls.map (d) ->
          ppl.append "<li><a href='/#/org/#{ctx.params.id}/newTelFor/#{d._id}'>#{d.name}</a></li>"

    @get '#/org/:id/rm': ->
      if confirm ('asdasd')
        $.post '/rmOrg', { id: @params.id }, (data) ->
          $('#smart').val ''
          findOrg()

    @get '#/org/:id/newTelFor/:ppl': (ctx) ->
      found = {}
      document.o.ppls.map (p) -> found = p if p._id is ctx.params.ppl
      if found
        content = $ '#btnPanel'
        content = $ '.content .phone-form' unless content.length
        block = $(blockTel ctx.params)
        block.find('input[name=who]').val(found.name)
        block.find('input[name=tel]').val(found.tel)
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
      $.post '/newOrg', { name: $('#smart').val() }, (data) ->
        findOrg()

    @get '#/org/:id/newTel': ->
      content = $ '#btnPanel'
      $(blockTel @params).replaceAll content
      $('#btnOtherPpl').click btnOtherPplPressed

    @get '#/org/:id/newTelOk': (ctx) ->
      block = $ '.content .phone-form'
      who = block.find('input[name=who]').val()
      txt = block.find('textarea[name=txtArea]').val()
      tel = block.find('input[name=tel]').val()

      $.post '/newTel', { other: block.attr('pplOther'), pplID: block.attr('pplID'), txt: txt, who: who, tel: tel, org: @params.id }, (data) ->
        ctx.redirect "#/org/#{ctx.params.id}"

    @get '#/': ->
      #@use 'Session'

    $(document).ready ->
      findOrg()

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
    if not @body.txt or not @body.org
      @send { err: 'nothing to do' }
      return
    that = @
    Org.findById @body.org, (err, res) ->
      that.send { err: 'Can not find Org' } if err or not res
      doc = new Doc { date: new Date, txt: that.body.txt, who: that.body.who, tel: that.body.tel  }
      res.docs.push doc
      console.log that.body
      if that.body.pplID and not that.body.otherPpl is 'true'
        console.log 'Got pplID', that.body.pplID
        res.ppls.map (p) ->
          if p._id.toString() is that.body.pplID
            console.log that.body
            p.name = that.body.who
            p.tel = that.body.tel
      else if that.body.who
        ppl = new Ppl { name: that.body.who, tel: that.body.tel }
        res.ppls.push ppl
      res.save (err) ->
        that.send { ok: yes }

  @get '/getOrgInfo/:id?': ->
    id = @params.id
    that = @
    Org.findById id, (err, res) ->
      that.send res

  @get '/findOrg/:name?': ->
    fnd = @params.name
    that = @
    Org
      .find({ name: new RegExp fnd, 'i' })
      .exclude('docs')
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
    
