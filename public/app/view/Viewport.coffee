Ext.define 'App.view.Viewport',
  extend: 'Ext.container.Viewport'
  layout: 'fit'
  requires: [ 'App.view.OrgList', 'App.view.TxtView' ]

  initComponent: ->
    Ext.apply @,
      items:
        layout: { type: 'hbox', align: 'stretch' }
        items: [
          width: 350, xtype: 'orgList'
        ,
          xtype: 'splitter'
        ,
          flex: 1, layout: { type: 'vbox', align: 'stretch' }
          items: [
            id: 'txt', flex: 1, xtype: 'txtview'
          ,
            xtype: 'splitter'
          ,
            id: 'ASD'
            height: 150, layout: { type: 'fit' }
            border: false
            items:
              xtype: 'textarea'
            dockedItems:
              xtype: 'toolbar', dock: 'bottom'
              items:
                id: 'btnOk'
                action: 'phoneCall'
                text: 'Телефонный звонок'
          ]
        ]
    @.callParent arguments
