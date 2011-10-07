(function() {
  Ext.define('App.controller.BaseCtrl', {
    extend: 'Ext.app.Controller',
    stores: ['Orgs'],
    models: ['Org'],
    refs: {
      ref: 'orgList',
      selector: 'orgList'
    },
    init: function() {
      console.log('controller.BaseCtrl init');
      return this.control({
        'orgList': {
          selectionchange: function(view, records) {
            var rec, txtPanel;
            rec = records.shift();
            txtPanel = Ext.getCmp('txt');
            return Org.getText({
              id: rec.data._id
            }, function(ans) {
              if (ans.success) {
                return txtPanel.update(ans.doc);
              } else {
                return txtPanel.update("ERROR: " + ans.message);
              }
            });
          }
        },
        'button[action=phoneCall]': {
          click: function(btn) {
            var id, txt, _ref, _ref2, _ref3;
            txt = btn.up().up().down('textareafield').value;
            id = (_ref = this.getOrgList().getSelectionModel().getSelection()) != null ? (_ref2 = _ref[0]) != null ? (_ref3 = _ref2.data) != null ? _ref3._id : void 0 : void 0 : void 0;
            if (txt && id) {
              return Org.setText({
                id: id,
                txt: txt
              }, function(ans) {
                var txtPanel;
                txtPanel = Ext.getCmp('txt');
                return txtPanel.update(ans);
              });
            }
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
