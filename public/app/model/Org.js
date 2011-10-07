(function() {
  Ext.define('App.model.Org', {
    extend: 'Ext.data.Model',
    fields: [
      {
        name: '_id',
        type: 'string'
      }, {
        name: 'name',
        type: 'string'
      }, {
        name: 'addr',
        type: 'string'
      }, {
        name: 'txt',
        type: 'string'
      }
    ]
  });
}).call(this);
