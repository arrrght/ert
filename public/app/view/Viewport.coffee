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
          flex: 1, layout: { type: 'vbox', align: 'stretch' }
          items: [
            id: 'txt', flex: 1,
            items:
              Ext.create 'Ext.view.View',
                tpl: [
                  '<tpl for=".">'
                  '<div class="thumb-wrap">'
                    '<div class="x-editable">{date}</div>'
                    '<span class="x-editable">{txt}</span>'
                  '</div>'
                  '</tpl>'
                  '<div class="x-clear"></div>'
                ]

                store: 'Docs'
                itemSelector: 'div.thumb-wrap'
          ,
            xtype: 'splitter'
          ,
            id: 'ASD'
            height: 150, layout: { type: 'fit' }
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
    this.callParent arguments
