@include = ->
  #include 'public/app/model/Org'
###
  Mongoose.model 'Org', new Mongoose.Schema
    addr: String
    name: String
    house: String
