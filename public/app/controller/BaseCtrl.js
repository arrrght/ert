(function() {
  var D;
  D = '';
  Ext.define('App.controller.BaseCtrl', {
    extend: 'Ext.app.Controller',
    stores: ['Orgs'],
    models: ['Org'],
    init: function() {
      console.log('controller.BaseCtrl init');
      return this.control({
        'orgList button[action=orgNew2]': {
          click: function() {
            return Org["new"]('asdadsad');
          }
        },
        'orgList button[action=orgNew]': {
          click: function(btn) {
            var filters, store, txt;
            store = this.getOrgsStore();
            filters = [];
            txt = btn.up().down('textfield[name=smart]').getValue();
            filters.push({
              property: 'name',
              value: txt
            });
            console.log(filters);
            store.filters.items = [];
            return store.filter(filters);
          }
        }
      });
    }
  });
}).call(this);
