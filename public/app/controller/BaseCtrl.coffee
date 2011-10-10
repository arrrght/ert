Ext.define 'App.controller.BaseCtrl',
  extend: 'Ext.app.Controller'

  stores: [ 'Orgs', 'Docs' ]
  models: [ 'Org', 'Doc' ]

  refs:
    ref: 'orgList', selector: 'orgList'

  init: ->
    @filterOrg = Ext.Function.createBuffered @filterOrg, 400

    @control
      'textfield[name=smart]': { change: @filterOrg }

      'orgList':
        selectionchange: @displayDocs
        itemcontextmenu: this.orgListContext

      'button[action=phoneCall]':
        click: (btn) ->
          txt = btn.up().up().down('textareafield').value
          id = @getOrgList().getSelectionModel().getSelection()?[0]?.data?._id
          store = @getDocsStore()
          if txt and id
            Org.setText { id: id, txt: txt }, (ans) ->
              store.loadData ans.docs

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

  orgListContext: (view, record, item, index, e) ->
    console.log 'E', e
    e.stopEvent()
    Ext.create('Ext.menu.Menu',
      items: [
        text: 'Удалить', handler: ->
          Org.rm { id: record.data._id }, (ok) ->
            console.log ok
          #record.store.remove record
      ]
    ).showAt e.getXY()

  displayDocs: (view, records) ->
    rec = records.shift()
    return unless rec
    txtPanel = Ext.getCmp 'txt'
    console.log 'txtPanel', txtPanel
    store = @getDocsStore()
    Org.getText { id: rec.data._id }, (ans) ->
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
