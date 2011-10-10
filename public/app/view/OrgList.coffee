Ext.define 'App.view.SmartField',
  extend: 'Ext.form.field.Trigger'
  alias: 'widget.smartfield'
  triggerCls: Ext.baseCSSPrefix + 'form-clear-trigger'
  onTrigger1Click : -> @setValue()

Ext.define 'App.view.OrgList',
  extend: 'Ext.grid.GridPanel'
  alias: 'widget.orgList'
  store: 'Orgs'
  tbar: [
    { xtype: 'smartfield', name: 'smart', emptyText: 'Поиск', flex:1 }
    { xtype: 'button', action: 'orgNew', text: 'Новая' }
  ]

  initComponent: ->
    Ext.apply @,
      selType: 'rowmodel'
      columns: [
        { header: 'Имя', dataIndex: 'name', flex: 1 }
      ]
    @callParent arguments
