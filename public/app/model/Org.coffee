Ext.define 'App.model.Org',
  extend: 'Ext.data.Model'
  requires: [ 'App.model.Doc', 'Ext.data.HasManyAssociation', 'Ext.data.BelongsToAssociation' ]
  fields: [
    { name: '_id', type: 'string' }
    { name: 'name', type: 'string' }
    { name: 'addr', type: 'string' }
    { name: 'txt', type: 'string' }
  ]

  hasMany:
    model: 'Doc', name: 'docs'

