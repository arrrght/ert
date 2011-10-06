@include = ->
  # Don't ask ((
  services = {}
  #def services: services

  # Entry in Ext.Direct
  @post '/direct/entry': ->
    console.log 'HEREHERHERHERHERHERHERHERHERHERHERHERHEREEEEEEEEEEEE'

    data = if @request.body instanceof Array then @request.body else [@request.body]
    dataL = data.length
    retArr = []

    data.map (rpc) ->
      console.log "SRV ↤ \x1b[32m#{rpc.action}.#{rpc.method} : #{rpc.tid}\x1b[0m"

      # Callback template
      reply =
        data: rpc.data.shift()
        ret: { action: rpc.action, method: rpc.method, tid: rpc.tid, type: rpc.type, result: {} }
        respond: ->
          console.log "SRV ↦ \x1b[32m#{@ret.action}.#{@ret.method} : #{rpc.tid}\x1b[0m"
          respond response, (if retArr.length > 1 then retArr else retArr.shift()) if --dataL < 1
        out: (result) ->
          @ret.result = result
          @ret.result.success ?= true
          retArr.push(@ret)
          @respond()

      # Call endpoint
      proc = services[rpc.action][rpc.method]
      proc.call this, reply

  # Regiser endpoint function
  endpoint = (name, fun) ->
    [cls, method] = name.split('.')
    services[cls] ?= {}
    services[cls][method] = fun

  # Respond answer to server
  respond = (response, obj) ->
    console.log 'Outta here ↦'
    body = JSON.stringify obj
    response.writeHead 200,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength body
    response.end body

  # Endpoint, actually
  endpoint 'Org.new', (reply) =>
    #console.log 'Here from Org.new:: ' + this
    #console.log reply.data

    Org = @Mongoose.model('Org')
    console.log "Model #{Org}"
    txt = reply.data.filter[0].value
    Org.find { name: new RegExp txt, 'i' }, (err, docs) ->
      reply.out docs

