Ext.define 'App.store.Orgs',
  extend: 'Ext.data.Store'
  model: 'App.model.Org'

  autoLoad: true
  remoteFilter: true
  remoteSorter: true

  proxy:
    type: 'direct'
    directFn: Org.find
