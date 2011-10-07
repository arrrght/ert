@include = ->
  # Don't ask ((
  services = {}
  #def services: services

  # Entry in Ext.Direct
  @post '/direct/entry': ->
    data = if @request.body instanceof Array then @request.body else [@request.body]
    dataL = data.length
    retArr = []
    resp = @response

    data.map (rpc) ->
      console.log "SRV ↤ \x1b[32m#{rpc.action}.#{rpc.method} : #{rpc.tid}\x1b[0m"

      # Callback template
      reply =
        data: rpc.data.shift()
        ret: { action: rpc.action, method: rpc.method, tid: rpc.tid, type: rpc.type, result: {} }
        respond: ->
          console.log "SRV ↦ \x1b[32m#{@ret.action}.#{@ret.method} : #{rpc.tid}\x1b[0m"
          respond resp, (if retArr.length > 1 then retArr else retArr.shift()) if --dataL < 1
        success: (result) ->
          result.success ?= true
          @out result
        failure: (result) ->
          result.success ?= false
          @out result
        out: (result) ->
          @ret.result = result
          retArr.push @ret
          @respond()

      # Call endpoint
      try
        proc = Ext.services[rpc.action][rpc.method].call this, reply
      catch e
        reply.failure e

  # Respond answer to server
  respond = (response, obj) ->
    body = JSON.stringify obj
    response.writeHead 200,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength body
    response.end body
