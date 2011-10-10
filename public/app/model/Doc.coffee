Ext.define 'App.model.Doc',
  extend: 'Ext.data.Model'
  fields: [
    { name: '_id', type: 'string' }
    { name: 'date', type: 'string' }
    { name: 'txt', type: 'string' }
  ]
  belongsTo: 'Org'
