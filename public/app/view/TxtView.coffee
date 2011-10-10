Ext.define 'App.view.TxtView',
  extend: 'Ext.view.View'
  layout: 'fit'
  alias: 'widget.txtview'

  initComponent: ->
    Ext.apply @,
      tpl: [
        '<tpl for=".">'
        '<div class="thumb-wrap">'
          '<div class="x-editable"><small>{date}</small></div>'
          '<span class="x-editable">{txt}</span>'
        '</div>'
        '<hr/>'
        '</tpl>'
        '<div class="x-clear"></div>'
      ]

      store: 'Docs'
      itemSelector: 'div.thumb-wrap'

    @.callParent arguments
