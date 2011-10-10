Ext.define 'App.controller.BaseCtrl',
  extend: 'Ext.app.Controller'

  stores: [ 'Orgs', 'Docs' ]
  models: [ 'Org', 'Doc' ]

  refs:
    ref: 'orgList', selector: 'orgList'

  filterTyre: ->
    ##

  init: ->
    console.log 'controller.BaseCtrl init'
    @filterOrg = Ext.Function.createBuffered @filterOrg, 400

    @control
      'textfield[name=smart]': { change: @filterOrg }

      'orgList':
        selectionchange: @displayDocs

      'button[action=phoneCall]':
        click: (btn) ->
          txt = btn.up().up().down('textareafield').value
          id = @getOrgList().getSelectionModel().getSelection()?[0]?.data?._id
          if txt and id
            Org.setText { id: id, txt: txt }, (ans) ->
              console.log ans
              txtPanel = Ext.getCmp 'txt'
              txtPanel.update ans.txt
              

      'orgList button[action=orgNew]':
        click: (btn) ->
          txt = btn.up().down('textfield[name=smart]').getValue()
          store = @getOrgsStore()
          Org.new { name: txt }, (ans) ->
            if ans.success
              store.filters.items = []
              store.filter [{ property: 'name', value: txt }]

      'orgList button[action=orgFind]':
        click: (btn) ->
          store = @getOrgsStore()
          filters = []

          txt = btn.up().down('textfield[name=smart]').getValue()
          filters.push property: 'name', value: txt
          console.log filters

          store.filters.items = []
          store.filter filters

  displayDocs: (view, records) ->
    rec = records.shift()
    txtPanel = Ext.getCmp 'txt'
    console.log 'txtPanel', txtPanel
    store = @getDocsStore()
    Org.getText { id: rec.data._id }, (ans) ->
      console.log ans
      if ans.success
        store.loadData ans.docs
      else
        txtPanel.update "ERROR: #{ans.message}"

  filterOrg: ->
    console.log 'Buffered'
    store = @getOrgsStore()
    txt = @getOrgList().down('textfield[name=smart]').getValue()
    filters = []

    filters.push property: 'name', value: txt

    store.filters.items = []
    store.filter filters
