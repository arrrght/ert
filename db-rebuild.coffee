#prm = require 'commander'

Mongoose = require 'mongoose'
conn = Mongoose.connect 'mongodb://localhost/foo2'
##
Doc2Schema = new Mongoose.Schema { touch: Date, org: Mongoose.Schema.ObjectId, author: Mongoose.Schema.ObjectId, txt: String, dat: Date }
Ppl2Schema = new Mongoose.Schema { touch: Date, org: Mongoose.Schema.ObjectId, name: String, post: String, tel: String }
Org2Schema = new Mongoose.Schema { touch: Date, name: String, addr: String }
Org2 = Mongoose.model 'org2', Org2Schema
Doc2 = Mongoose.model 'doc2', Doc2Schema
Ppl2 = Mongoose.model 'ppl2', Ppl2Schema


#Mongoose.disconnect()
#conn.close()
## Temporary ones
#Zk = Mongoose.model 'z_kontakt', new Mongoose.Schema { nn2: Number }

#db = require('mongoskin').db('localhost:27017/foo2')
#zk = db.collection('z_kontakts')

#prm
#  .version('0.0.1')
#  .option('-r, --rebuild', 'Rebuild DB')
#  .parse process.argv

fb = require 'firebird' # FUCKED database
Buffer = require('buffer').Buffer
Iconv = require('iconv').Iconv
cnv = new Iconv 'CP1251', 'UTF-8'

getTxt = (o) -> # Fetch and convert from CP1251 to UTF8
  buf = new Buffer(4096)
  o._openSync()
  len = o._readSync(buf)
  o._closeSync()
  (cnv.convert buf.slice(0, len)).toString().replace(/\x0D\x0A/g, '\n').replace /\n$/, ''

fetchOne = (sql) ->
  try conn.querySync(sql).fetchSync(1, true).shift()

fetchK = (id) -> # Don't care id died
  fetchOne "select FIRST 1 * from KONTAKTS where ID > #{id} ORDER BY ID"
  #fetchOne "select FIRST #{first} * from KONTAKTS where ID>#{from} order by ID"

conn = fb.createConnection()
conn.connectSync '10.96.0.162/3045/C:\\SKYAPM\\BASE.GDB', 'sysdba', 'fbclient.dll', ''

# first, get all count
now = conn.querySync('select count(*), max(ID), min(ID) from KONTAKTS').fetchSync(1, true).shift()
getOrg = (id) ->
  fetchOne "select * from ENPRISE where NN2 = #{id}"

# Main process
proceed = (row) ->
  org = getOrg row.NN2
  console.log org
  process.exit()
  #org = db.org2s.findOne({ sky_id: i.NN2 });
  #console.log row.ID

Org2.remove {}, ->
  Doc2.remove {}, ->
    Ppl2.remove {}, ->
      # Fetch by one
      nowID = now.MIN-1
      while nowID <= now.MAX
        row = fetchK nowID
        console.log 'GOT', nowID
        if row
          nowID = row.ID
          proceed row
        else
          console.log 'DIE', ++nowID
