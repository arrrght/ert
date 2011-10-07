(function() {
  Ext.define('App.store.Orgs', {
    extend: 'Ext.data.Store',
    model: 'App.model.Org',
    autoLoad: true,
    remoteFilter: true,
    remoteSorter: true,
    proxy: {
      type: 'direct',
      directFn: Org.find
    }
  });
  /*
    data: [
      { id: 1, name: 'asdad', addr: 'asdasdad' }
      { id: 2, name: '23123', addr: '11212141' }
    ]*/
}).call(this);
