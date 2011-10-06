(function() {
  Ext.define('App.view.OrgList', {
    extend: 'Ext.grid.GridPanel',
    alias: 'widget.orgList',
    store: 'Orgs',
    tbar: [
      {
        xtype: 'textfield',
        name: 'smart',
        emptyText: 'Поиск',
        flex: 1
      }, {
        xtype: 'button',
        action: 'orgNew',
        text: 'New'
      }, {
        xtype: 'button',
        action: 'orgNew2',
        text: 'New2'
      }
    ],
    initComponent: function() {
      console.log('view.OrgList init');
      Ext.apply(this, {
        selType: 'rowmodel',
        columns: [
          {
            header: 'Num',
            dataIndex: 'id',
            width: 30
          }, {
            header: 'Имя',
            dataIndex: 'name',
            flex: 1
          }
        ]
      });
      return this.callParent(arguments);
    }
  });
}).call(this);
