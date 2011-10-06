Ext.define 'App.view.Viewport',
  extend: 'Ext.container.Viewport'
  layout: 'fit'
  requires: [ 'App.view.OrgList' ]

  initComponent: ->
    console.log 'view.Viewport init'
    Ext.apply this,
      items:
        layout: { type: 'hbox', align: 'stretch' }
        items: [
          width: 350, xtype: 'orgList'
        ,
          xtype: 'panel'
          dockedItems:
            xtype: 'toolbar', dock: 'bottom'
            items:
              text: 'Телефонный звонок'
          html: 'right<b>bold</b>', flex: 1
        ]
    this.callParent arguments
