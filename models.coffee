Mongoose = require 'mongoose'
Schema = Mongoose.Schema
ObjectId = Mongoose.Schema.ObjectId

exports.Org2 = Mongoose.model 'org2',
  new Schema
    sky_id: Number
    touch: Date
    name: String
    addr: String
    url: String
    inn: String
    xAddr:
      zip: String
      street: String
      house: String
      liter: String
      city: String
      addr: String
      obl: String
      office: String
      ext: String
    phone: String
    pCode: String
    ppls: [
      type: ObjectId
      ref: 'ppl2'
    ]

exports.Ppl2 = Mongoose.model 'ppl2',
  new Schema
    sky_id: Number
    sky_ppl: String
    ppl_id: Number
    touch: Date
    org:
      type: ObjectId
      ref: 'org2'
    name: String
    post: String
    tel: String

exports.Doc2 = Mongoose.model 'doc2',
  new Schema
    dbg: String
    sky_id: Number
    sky_doc_id: Number
    is_parsed: Boolean
    touch: Date
    org:
      type: ObjectId
      ref: 'doc2'
    author:
      type: ObjectId
      ref: 'ppl2'
    txt: String
    dat: Date

