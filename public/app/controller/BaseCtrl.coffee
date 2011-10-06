D = ''
Ext.define 'App.controller.BaseCtrl',
  extend: 'Ext.app.Controller'

  stores: [ 'Orgs' ]
  models: [ 'Org' ]

  init: ->
    console.log 'controller.BaseCtrl init'
    this.control

      'orgList button[action=orgNew2]':
        click: -> Org.new('asdadsad')

      'orgList button[action=orgNew]':
        click: (btn) ->
          store = @getOrgsStore()
          filters = []

          txt = btn.up().down('textfield[name=smart]').getValue()
          filters.push property: 'name', value: txt
          console.log filters

          store.filters.items = []
          store.filter filters
