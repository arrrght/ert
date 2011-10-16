doctype 5
html ->
  head ->
    title "ert3"
    link href: '/css/bootstrap.min.css', rel: 'stylesheet'
    style type: 'text/css', '''
      body { padding-top: 60px; }
      .topbar .btn { border: 0; } 
      .container-fluid > .sidebar { float: left; width: 333px; }
      .container-fluid > .content { margin-left: 353px; } 
      .well { padding: 12px; padding-top: 0px; padding-bottom: 0px; }
      .well input { margin-bottom: 10px; }
      .pull-right button { margin-left: 2px; }
      h2 { margin-top: -16px; }
      .xsmall { height: 8px; font-size: 10px; margin-left: 8px; padding-top: 2px; margin-bottom: -4px; }
      .tel blockquote { margin-top: 16px; }
      .w_input ul { padding-top: 38px; }
    '''
body ->
  div class: 'topbar', ->
    div class: 'topbar-inner', ->
      div class: 'container-fluid', ->
        a class: 'brand', href: '#', 'ProjectName'
        ul class: 'nav', ->
          li class: 'active', -> a href: '#', 'Home'
          li -> a href: '#', 'Home'
          li -> a href: '#', 'Home'
        form action: '', class: 'pull-right', ->
          input class: 'input-small', type: 'text', placeholder: 'Username'
          input class: 'input-small', type: 'password', placeholder: 'Password'
          button class: 'btn', type: 'submit', 'Вход'

  div class: 'container-fluid', ->

    div class: 'sidebar', ->
      div class: 'well w_input', ->
        h5 'Организации'
        div class: 'input', ->
          div class: 'input-append', ->
            input class: 'span5', type: 'text', placeholder: 'Поиск...'
            label class: 'add-on', ->
              a href: '#', class: 'button', 'X'
        ul ->
          li -> a href: '#', 'Бошняковский угольный разрез'
          li -> a href: '#', 'Полюс Золото'
          li -> a href: '#', 'Щербинский механический завод'
          li -> a href: '#', 'АХРСУ Гескол имени Ленина, трижды краснознаменный'

      div class: 'well', ->
        h5 'Задачи'
        ul ->
          li -> a href: '#', 'Задача 1'
          li -> a href: '#', 'Задача 1'
          li -> a href: '#', 'Задача 1'

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
        h4 'Полюс Золото'
        blockquote ->
          p 'Слушай сюда. Ты эти четыре трактора перебрось… в Березовку… перебрось! Пойдут! Завтра доложишь. Все!'
          small 'Станислав Пынзарь'

      div class: 'well', ->
        a href: '#', ->
          h4 'Бошняковский угольный разрез'
        blockquote ->
          p 'Через пару минут в кабинет вошел Ивлев, лет тридцати человек, поджарый, смуглый, с резкими морщинами около рта, с живыми умными глазами. Тоже, видать, устал, он держится прямо, легко – подвижный. Одет с иголочки: новые галифе, новый китель, новые хромовые сапоги мягко горят черным блеском. Хорошо, грит, давайте мне ваши <span class="label important">45/65-45</span>. Жахнул рукуо об стол и продолжил - "Два десятка!"'
          small 'Станислав Пынзарь'

      div class: 'well tel', ->
        blockquote ->
          p 'Что хочет не понятно'
          small 'Звонок менеджеру по закупкам Михаилу Алексеевичу +7 922 12-23-443'

      div class: 'well tel', ->
        blockquote ->
          p 'Еще сегодня был на месте, но сегодня уже не будет. Перезвоните завтра после обеда'
          small 'Секретарь + 7 (34312) 2-54-11'
