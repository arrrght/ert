[fs, coffee] = [require('fs'), require('coffee-script')]

# Placehiolder for services
exports.services = {}

# ExtJS define
exports.define = (extName, extData) ->
  [_, extType, extName] = extName.split '.'
  @[extType](extName, extData)

# ExtJS Model parsing
exports.model = (extName, extData) ->
  fld = {}
  cnvType = (t) ->
    if (t == 'string')
      return String
    else if(t == 'float')
      return Number

  extData.fields.map (fldName) ->
    fld[fldName.name] = cnvType(fldName.type) unless fldName.name is '_id'

  console.log 'Model', extName, fld
  @[extName] = Mongoose.model extName, new Mongoose.Schema fld

# Eval file
exports.evalFile = (fileName) ->
  file = fs.readFileSync "#{__dirname}/public/app/#{fileName}.coffee", 'utf8'
  coffee.eval file, { sandbox: { Ext: @ }}

# Regiser endpoint function
exports.endpoint = (name, fun) ->
  [cls, method] = name.split('.')
  @services[cls] ?= {}
  @services[cls][method] = fun
