@include = ->
  @client '/index.js': ->
    
    # TODO get all redirects from sammy
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
      #console.log 'Parse DATE', d, new Date(d), new Date(d).getMonth()
      d = if d then new Date(d) else new Date()
      mo = 'января февраля марта апреля мая июня июля августа сентября октября ноября декабря'.split ' '
      da = 'воскресенье понедельник вторник среда четверг пятница суббота'.split ' '
      "#{da[d.getDay()]}, #{d.getDate()} #{mo[d.getMonth()]} #{d.getFullYear()} г."

    # Поиск организации
    findOrg = (name) ->
      fnd = $('#smart').val()
      $.getJSON "/findOrg/#{fnd}", (data) ->
        $('.sidebar .orgs').empty()
        $('.sidebar .ppls').hide()
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
      "<h2><a>#{params.name}</a></h2>"
      "<span id='btnPanel'>"
      "</span>"
      "<div class='well org-info XXXhidden'>"
      "<br/><address><strong class='chInfo'>Адрес:</strong> "
      "<nobr>Индекс: #{params.xAddr.zip},</nobr> " if params.xAddr?.zip
      "<nobr>Город: #{params.xAddr.city},</nobr> " if params.xAddr?.city
      "<nobr>Адрес: #{params.xAddr.addr},</nobr> " if params.xAddr?.addr
      "<nobr>Интернет: <a href='http://#{params.url}'>#{params.url}</a>,</nobr> " if params.url
      "<nobr>Телефоны: #{params.phone},</nobr> " if params.phone
      #(->
      #  arr =
      #    'Индекс': params.xAddr.zip
      #    'Город': params.xAddr.city
      #    'Адрес': params.xAddr.addr
      #    #'Улица': params.xAddr.street
      #    #'Дом': params.xAddr.house
      #    'Интернет': params.url
      #    'Телефон': params.phone
      #  ret = ''
      #  for k,v of arr
      #    ret += "<nobr>#{k}: #{v},</nobr> " if v
      #  ret
      #)()
      "</address></div>"
    ].join ''
    
    # Org body
    blockOrgBody = (params) -> [
      "<div class='well tel'><blockquote>"
        "<p>#{params.txt.replace /\n/g, '<br/>'}</p>"
        "<small>"
        if params.dat then showDate(params.dat) else params.date
        " ⇽ #{params.author?.name}"
        " ⇿ #{params.who}" if params.who
        " ⇽ #{params.tel}" if params.tel
        "</small>"
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

    ## getOrg with fillout
    getAndFillOrg = (id, callback) ->
      content = $ '.content'
      ppl = $ '.ppls ul'
      $.getJSON "/getOrgInfo/#{id}", (data) ->
        document.o = data
        content.empty()
        content.append blockOrgHead data.org
        data.docs.map (d) -> content.append blockOrgBody d
        # map Ppl
        ppl.replaceWith '<ul>' + ((data.ppls.map (d) -> blockOrgPpl d, id).join '') + '</ul>'
        if data.ppls.length > 0 then show('.ppls') else hide('.ppls')
        $('.content h2 a').click -> $('.content .org-info').toggle(99)
        $('.content .org-info .chInfo').dblclick -> console.log 'CHANGE'
        callback() if callback

    # JQuery helpers
    show = (prm...) -> prm.map (p) -> $(p).show()
    hide = (prm...) -> prm.map (p) -> $(p).hide()

    # Routes (sammy)
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
      # TODO remove that crap -> document.o
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
                  "#{showDate(d.doc.dat)}, #{d.doc.author.name}, телефонный звонок: #{d.doc.who}, по телефону #{d.doc.tel}"
                "</small>"
              "</blockquote>"
            "</div>"
          ].join ''
      buttonsOn 'root'

    $(document).ready ->
      $('.topbar').dropdown()

      #$('.container-fluid:first').append "<small class='date'>#{showDate()}</small>"
      findOrg()

      # Buttons bind
      # Новый телефонный разговор
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
