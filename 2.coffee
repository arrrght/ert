require('zappa') ->
  @enable 'default layout'

  @get '/': ->
    @user = plan: 'staff'

    #@render 'index', { @user, postrender: 'plans' }
    @render 'index', { @user, postrender: 'plans' }

  @postrender plans: ($) ->
    $('button').remove()

  @view index: ->
    @title = 'Title'

    h1 'Quotas:'
    div id: 'quotas', ->
      div class: 'basic', ->
        h2 'Basic'
        p 'Disk: 1Gb'
        p 'Bandwitch: 10Gb'
