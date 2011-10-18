require('zappa') ->
  @use 'bodyParser', 'methodOverride', @app.router, 'static'
  @use errorHandler: { dumpExceptions: on, showStack: on }
  @use @express.logger({ format: '\x1b[32m:method\x1b[0m \x1b[33m:url\x1b[0m :response-time ms' })
  @enable 'serve sammy', 'minify', 'serve jquery'

  global.Mongoose = require 'mongoose'
  Mongoose.connect 'mongodb://localhost/foo2'

  # Schemas
  DocSchema = new Mongoose.Schema { author: String, date: String, txt: String }
  PplSchema = new Mongoose.Schema { name: String, post: String }
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
        #console.log data
        $('.sidebar .orgs').empty()
        data.map (d) ->
          $('.sidebar .orgs').append "<li><a href='#/org/#{d._id}'>#{d.name}</a></li>"

    # Routes (sammy)
    # Org view
    @get '#/org/:id': ->
      console.log 'Got that', @
      content = $ '.content'
      ppl = $ '.ppls ul'
      $.getJSON "/getOrgInfo/#{@params.id}", (data) ->
        console.log data
        content.empty()
        content.append "<h2>#{data.name}</h2>"
        content.append "<a href='/#/org/#{data._id}/newTel' class='btn xsmall success activePanel'>Новый телефонный разговор</a>"
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
          ppl.append "<li><a href='/#/newTelFor/#{d._id}'>#{d.name}</a></li>"

    @get '#/org/:id/newTel': ->
      content = $ '.content a'
      console.log 'Got', content
      block = [
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
          "<a href='/#/org/#{@params.id}/newTelOk' class='btn success pull-right btn-ok'>OK</a>"
          "</blockquote>"
        "</div>"
      ].join ''

      $(block).replaceAll content

    @get '#/org/:id/newTelOk': (ctx) ->
      txt = $('.phone-form textarea[name=txtArea]').val()
      who = $('.phone-form input[name=who]').val()
      tel = $('.phone-form input[name=tel]').val()
      console.log 'GOT::', txt, who, tel
      $.post '/newTel', { txt: txt, who: who, tel: tel, org: @params.id }, (data) ->
       ctx.redirect "#/org/#{ctx.params.id}"


    $(document).ready ->
      findOrg()

      $('#btn-ok').click ->
        console.log 'HI'

      $('input[id=smart]').change (e) -> findOrg()
      $('#smart-clear').click (e) ->
        $('#smart').val('')
        findOrg()
  # End-of-client

  # Server-side
  # Новый телефонный разговор
  @post '/newTel', ->
    @send { err: 'nothing to do' } if not @body.txt or not @body.org
    that = @
    console.log 'got', @body
    Org.findById @body.org, (err, res) ->
      that.send { err: 'Can not find Org' } if err or not res
      doc = new Doc { date: new Date, txt: that.body.txt, who: that.body.who, tel: that.body.tel  }
      res.docs.push doc
      if that.body.who
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
    console.log 'fnd:', fnd
    Org
      .find({ name: new RegExp fnd, 'i' })
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
    
