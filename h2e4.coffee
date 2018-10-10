[fs, coffee] = [require('fs'), require('coffee-script')]

# Placeholder for services
exports.services = {}

# Placeholder for api
exports.appi = {}

# Write out /api.js
exports.api = ->
  result = { type: 'remoting', url: '/direct/entry', actions: Ext.appi }
  @response.writeHead 200, { 'Content-type': 'text/javascript' }
  @response.write 'Ext.app.REMOTING_API=' + JSON.stringify result
  @response.end ';Ext.Direct.addProvider(Ext.app.REMOTING_API);Ext.app.REMOTING_API.enableBuffer=100;'

# Schemas
exports.Schemes = {}

# ExtJS define
exports.define = (extName, extData) ->
  [_, extType, extName] = extName.split '.'
  @[extType](extName, extData)

# ExtJS Model parsing
exports.model = (extName, extData) ->
  return yes if @Schemes[extName]
  fld = {}
  cnvType = (t) ->
    if (t == 'string')
      return String
    else if(t == 'float')
      return Number

  extData.fields.map (fldName) ->
    fld[fldName.name] = cnvType(fldName.type) unless fldName.name is '_id'

  console.log 'Extracting model', extName

  # Parsing hasMany
  if extData.hasMany
    exports.evalFile "model/#{extData.hasMany.model}"
    fld[extData.hasMany.name] = [@Schemes[extData.hasMany.model]]

  @Schemes[extName] = new Mongoose.Schema fld
  @[extName] = Mongoose.model extName, new Mongoose.Schema fld

# Eval file
exports.evalFile = (fileName) ->
  file = fs.readFileSync "#{__dirname}/public/app/#{fileName}.coffee", 'utf8'
  coffee.eval file, { sandbox: { Ext: @ }}

# Register endpoint function
# prm like { formHandler : yes, len: 999 }
# prm may skipped
exports.endpoint = (name, prm, fun) ->
  fun = prm if prm instanceof Function
  [cls, method] = name.split('.')
  exports.appi[cls] ?= []
  def = { name: method, len: 1 } # defaults
  def[key] = prm[key] for key in 'len:name:formHandler'.split ':' when prm[key] if prm isnt fun
  exports.appi[cls].push def
  @services[cls] ?= {}
  @services[cls][method] = fun

# Entry
exports.entry = ->
  data = if @request.body instanceof Array then @request.body else [@request.body]
  dataL = data.length
  [retArr, resp] = [[], @response]

  retSt = (result) -> if result.success then '\x1b[32mSuccess\x1b[0m' else '\x1b[31mFailure\x1b[0m'
  data.map (rpc) ->
    console.log "SRV ↤ \x1b[32m#{rpc.action}.#{rpc.method} : #{rpc.tid}\x1b[0m"

    # Callback template
    reply =
      data: rpc.data.shift()
      ret: { action: rpc.action, method: rpc.method, tid: rpc.tid, type: rpc.type, result: {} }
      respond: ->
        console.log retSt(@ret.result) + " SRV ↦ \x1b[32m#{@ret.action}.#{@ret.method} : #{rpc.tid}\x1b[0m"
        exports.writeOut resp, (if retArr.length > 1 then retArr else retArr.shift()) if --dataL < 1
      success: (result) ->
        result = { message: result } if result instanceof String
        result.success ?= true
        @out result
      failure: (result) ->
        result = { message: result } if result instanceof String
        result.success ?= false
        @out result
      out: (result) ->
        @ret.result = result
        retArr.push @ret
        @respond()

    # Call endpoint
    try
      proc = exports.services[rpc.action][rpc.method].call this, reply
    catch e
      reply.failure e

# Respond answer to server
exports.writeOut = (resp, obj) ->
  body = JSON.stringify obj
  resp.writeHead 200,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength body
  resp.end body
