doctype 5
html ->
  head ->
    title @title or 'ERT'
    link href: '/css/bootstrap.min.css', rel: 'stylesheet'
    script src: '/zappa/jquery.js'
    script src: '/zappa/zappa.js'
    script src: '/zappa/sammy.js'
    script src: '/index.js'
    noscript 'Браузер не поддерживает JavaScript.'
    style type: 'text/css', '''
      body { padding-top: 60px; }
      .topbar .btn { border: 0; } 
      .container-fluid { height: 40px; }
      .container-fluid > .sidebar { float: left; width: 333px; }
      .container-fluid > .content { margin-left: 353px; } 
      .well { padding: 12px; padding-top: 0px; padding-bottom: 0px; }
      .well input { margin-bottom: 10px; }
      .pull-right button { margin-left: 2px; }
      h2 { margin-top: -16px; }
      .xsmall { height: 8px; font-size: 10px; margin-left: 8px; padding-top: 2px; margin-bottom: -4px; }
      .activePanel { margin-bottom: 8px; }
      .w_input ul { padding-top: 38px; }
      .phone-form blockquote { margin-top: 0px; }
      .phone-form blockquote .inline-inputs { margin-top: 12px; }
      .phone-form blockquote .inline-inputs span { margin-left: 12px; margin-right: 12px; }
      .phone-form .pull-right { margin-top: -24px; margin-right: -4px; }
      .phone-form .pull-right .btn { margin-left: 8px; }
      .phone-form .pull-right :last-child { margin-right: 0px; }
      .phone-form .inline-inputs :first-child { margin-left: -16px; }
      .bar-btn-group { margin-top: 5px; margin-right: 8px; }
      .container-fluid .date { color: #777777 }
      .content .well blockquote { margin-top: 8px; margin-bottom: 8px; }
      .content .well { margin-bottom: 8px; }
      XXX .content .well h4 a { color: black }
      .content .well h4 { margin-bottom: -10px; }
    '''
body ->
  div class: 'topbar', ->
    div class: 'topbar-inner', ->
      div class: 'container-fluid', ->
        a class: 'brand', href: '#/', ->
          text 'ERT'
        #small 'Среда, 23 января 2011 г.'
        #ul class: 'nav pull-right', ->
          #li class: 'active', -> a href: '#', 'Home'
          #li -> a href: '#', 'Home'

        #form class: 'pull-right', ->
        #  input class: 'input-small', type: 'text', placeholder: 'Username'
        #  input class: 'input-small', type: 'password', placeholder: 'Password'
        #  button class: 'btn', type: 'submit', 'Вход'
        div class: 'bar-btn-group pull-right', ->
          button class: 'btn small danger', id: 'btn-rm-org', 'Удалить компанию'
          button class: 'btn small danger', id: 'btn-rm-ppl', 'Удалить человека'
          button class: 'btn small success', id: 'btn-add-tel', '+ телефонный разговор'
          #a href: '/#/org/#{params._id}', class: 'btn success', 'ASDASDASD'

  div class: 'container-fluid', ->

    div class: 'sidebar', ->
      div class: 'well w_input', ->
        h5 ->
          text 'Организации'
          a href: '/#/newOrg', class: 'btn xsmall danger', 'Новая'
        div class: 'input', ->
          div class: 'input-append', ->
            input class: 'span5', type: 'text', id: 'smart', placeholder: 'Поиск...'
            label class: 'add-on', ->
              a href: '/#/', class: 'button', id: 'smart-clear', 'X'

        # Sample orgs
        ul class: 'orgs', ->
          #li -> a href: '#', 'Бошняковский угольный разрез'
          #li -> a href: '#', 'Полюс Золото'
          #li -> a href: '#', 'Щербинский механический завод'
          #li -> a href: '#', 'АХРСУ Гескол имени Ленина, трижды краснознаменный'

      # Sample people
      div class: 'well ppls', ->
        h5 'Сотрудники'
        ul ->
          #li -> a href: '#', 'Анатолий Иванович <span class="label">менеджер по продажам</span>'
          #li -> a href: '#', 'Алексей Федорович Крузерштерн <span class="label">директор<span>'
          #li -> a href: '#', 'Василий Иванович'

      # Sample Tasks [ not workin' ]
      #div class: 'well', ->
      #  h5 'Задачи [ пока не работает ]'
      #  ul ->
      #    li -> a href: '#', 'Задача 123'
      #    li -> a href: '#/job/1', 'Задача 1'
      #    li -> a href: '/new', 'Задача 1'

    div class: 'content', ->
      h2 'Последние действия'

      div class: 'well', ->
        h4 ->
          text 'Щербинский механический завод'
          a href: '#', class: 'btn xsmall success', 'Далее..'
        blockquote ->
          p 'Врут нагло, припираясь на каждом слове, но шины хотят, и сильно. С чем это связано - непонятно, но уж очень хотят. На предложение отгрузить им пару составов <span class="label important">23.5-35</span> согласны, но только <span class="label warning">Titan</span>. Сволочи, чо.'
          small 'Тарас Атаманкин'

      div class: 'well', ->
        h4 ->
          text 'АХРСУ Гескол имени Ленина, трижды краснознаменный'
          a href: '#', class: 'btn xsmall success', 'Далее..'
        blockquote ->
          p 'Секретарь Татьяна говорит что директор на месте, но директор трубку не береет третий день. У них же <span class="label success">Komatsu HD1500</span> простаивает'
          small 'Дмитрий Дурыгин, звонок менеджеру по закупкам Стапину В.В. + 7 (123) 345-09-10'

      div class: 'well', ->
        h4 -> a href: '#', 'Полюс Золото'
        blockquote ->
          p 'Слушай сюда. Ты эти четыре трактора перебрось… в Березовку… перебрось! Пойдут! Завтра доложишь. Все!'
          small 'Станислав Пынзарь'

      div class: 'well', ->
        a href: '#', -> h4 'Бошняковский угольный разрез'
        #h4 -> a href:'#', 'Бошняковский угольный разрез'
        blockquote ->
          p 'Через пару минут в кабинет вошел Ивлев, лет тридцати человек, поджарый, смуглый, с резкими морщинами около рта, с живыми умными глазами. Тоже, видать, устал, он держится прямо, легко – подвижный. Одет с иголочки: новые галифе, новый китель, новые хромовые сапоги мягко горят черным блеском. Хорошо, грит, давайте мне ваши <span class="label important">45/65-45</span>. Жахнул рукуо об стол и продолжил - "Два десятка!"'
          small 'Станислав Пынзарь'

      div class: 'well tel', ->
        blockquote ->
          p 'Что хочет не понятно'
          small 'Звонок менеджеру по закупкам Михаилу Алексеевичу +7 922 12-23-443'

      div class: 'well tel', ->
        blockquote ->
          p 'Еще сегодня был на месте, но сегодня уже не будет. Перезвоните завтра после обеда <a href="#/job/asd">XXXXXX</a>'
          small 'Секретарь + 7 (34312) 2-54-11'
