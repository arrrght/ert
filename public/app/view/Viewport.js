(function() {
  Ext.define('App.view.Viewport', {
    extend: 'Ext.container.Viewport',
    layout: 'fit',
    requires: ['App.view.OrgList'],
    initComponent: function() {
      console.log('view.Viewport init');
      Ext.apply(this, {
        items: {
          layout: {
            type: 'hbox',
            align: 'stretch'
          },
          items: [
            {
              width: 350,
              xtype: 'orgList'
            }, {
              flex: 1,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              items: [
                {
                  flex: 1,
                  xtype: 'panel',
                  id: 'txt',
                  html: 'right<b>bold</b>',
                  flex: 1
                }, {
                  xtype: 'splitter'
                }, {
                  id: 'ASD',
                  height: 150,
                  layout: {
                    type: 'fit'
                  },
                  items: {
                    xtype: 'textarea'
                  },
                  dockedItems: {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    items: {
                      id: 'btnOk',
                      action: 'phoneCall',
                      text: 'Телефонный звонок'
                    }
                  }
                }
              ]
            }
          ]
        }
      });
      return this.callParent(arguments);
    }
  });
}).call(this);
