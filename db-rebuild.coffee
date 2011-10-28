Mongoose = require 'mongoose'
async = require 'async'
conn = Mongoose.connect 'mongodb://localhost/foo2'

fb = require 'firebird' # FUCKED database
conn = fb.createConnection()
conn.connectSync '10.96.0.162/3045/C:\\SKYAPM\\BASE.GDB', 'sysdba', 'fbclient.dll', ''

Buffer = require('buffer').Buffer
Iconv = require('iconv').Iconv
cnv = new Iconv 'CP1251', 'UTF-8'

Org2 = Mongoose.model 'org2',
  new Mongoose.Schema
    sky_id: Number
    touch: Date
    name: String
    addr: String

Ppl2 = Mongoose.model 'ppl2',
  new Mongoose.Schema
    ppl_id: Number
    touch: Date
    org: Mongoose.Schema.ObjectId
    name: String
    post: String
    tel: String

Doc2 = Mongoose.model 'doc2',
  new Mongoose.Schema
    dbg: String
    sky_id: Number
    sky_doc_id: Number
    is_parsed: Boolean
    touch: Date
    org:
      type: Mongoose.Schema.ObjectId
      ref: 'doc2'
    author:
      type: Mongoose.Schema.ObjectId
      ref: 'ppl2'
    txt: String
    dat: Date

ERTID = 0

#Mongoose.disconnect()
#conn.close()

fb_getTxt = (o) -> # Fetch and convert from CP1251 to UTF8, remove all cr-lf to cr and rm last
  buf = new Buffer(4096)
  o._openSync()
  len = o._readSync(buf)
  o._closeSync()
  (cnv.convert buf.slice(0, len)).toString().replace(/\x0D\x0A/g, '\n').replace /\n$/, ''

fb_fetchOne = (sql) ->
  try
    return conn.querySync(sql).fetchSync(1, true).shift()
  catch e
    console.log 'DIED', e

fb_fetchUser = (id) ->
  console.log 'fb_fetchUser', id
  fb_fetchOne "select FIRST 1 NAME, ID, DOLZHN from WORKS where ID = #{id}"

fb_fetchK = (id) ->
  console.log 'fb_fetchK', id
  fb_fetchOne "select FIRST 1 * from KONTAKTS where ID > #{id} ORDER BY ID"
  #fb_fetchOne "select FIRST 1 * from KONTAKTS where ID > #{id} AND NN2 = 500296 ORDER BY ID"

fb_getOrg = (id) ->
  console.log 'fb_org', id
  fb_fetchOne "select NN2, FULLNAME from ENPRISE where NN2 = #{id}"

# MY find or create user
my_getUser = (sky_user_id, callback) ->
  console.log 'Proceed find MY USER', sky_user_id
  Ppl2.find({ sky_id: sky_user_id, org: ERTID }).limit(1).execFind (err, my_user) ->
    if my_user.length isnt 0
      o = my_user.shift()
      console.log 'MY user found'
      callback o
    else
      sky_user = fb_fetchUser sky_user_id
      (new Ppl2({ sky_id: sky_user.ID, org: ERTID, name: sky_user.NAME, post: sky_user.DOLZHN })).save (err, res) ->
        console.log 'My USER created', res.name
        callback res
      
# MY find or create org
my_getOrg = (sky_org_id, callback) ->
  console.log 'Proceed find MY ORG', sky_org_id
  Org2.find({ sky_id: sky_org_id }).limit(1).execFind (err, my_org) ->
    if my_org.length isnt 0
      o = my_org.shift()
      console.log 'MY org found', o.name
      callback o
    else
      sky_org = fb_getOrg sky_org_id
      console.log 'get SKY ORG', sky_org_id
      org = new Org2 { name: sky_org.FULLNAME, sky_id: sky_org.NN2 }
      org.save (err, res) ->
        console.log 'MY ORG created', org.name
        callback res

# FB doc + time -> doc.time
fb_date = (dat, tim) ->
  [p_dat, p_tim] = [new Date(dat), new Date(tim)]
  d = new Date p_dat.getFullYear(), p_dat.getMonth(), p_dat.getDate()-1, p_tim.getHours()+1, p_tim.getMinutes(), p_tim.getSeconds()

create_doc = (doc, callback) ->
  (new Doc2(doc)).save (err, res) ->
    callback res

my_getDoc = (sky_org_id, callback) -> Doc2.find({ sky_org_id: sky_org_id }).execFind (err,res) -> callback res

my_findOrCreatePpl = (sky_doc, callback) ->
  callback()

process_doc = (sky_doc, user, my_org, callback) ->
  txt = fb_getTxt sky_doc.TXT
  #console.log 'TXTALL\n', txt, '\nEND-OF-TXTALL'
  tF = txt.match /\s*(\d+\.\d+\.\d+.+)/mg
  # FILL PPL TODO
  #console.log sky_doc
  #my_findOrCreatePpl sky_doc, ->
    #conole.log '@!$!'
  #
  if tF
    jobs = []
    tF.map (t) ->
      t = t.replace /(^\n+)|(\n+$)/, ''
      #console.log 't:', t
      dtP = t.match /^\s*(\d+)\.(\d+)\.(\d+)\s*(.+)$/
      dtP[3] = '20'+dtP[3] if String(dtP[3]).length is 2
      dt = new Date dtP[3], dtP[2], dtP[1]*1+1, -19 # WTF? -19 hours?
      doc =
        dbg: t
        sky_id: sky_doc.ID
        sky_org_id: sky_doc.NN2
        author: user._id
        touch: fb_date(sky_doc.DATA2, sky_doc.TIME2)
        dat: dt
        org: my_org._id
        tel: sky_doc.PHONES
        txt: dtP[4]
        who: sky_doc.SUBJECT
        sky_manager_id: sky_doc.MANAGER

      jobs.push (cb) ->
        my_getDoc sky_doc.NN2, (fnd_docs) ->
          found = false
          fnd_docs.map (d) -> found = true if d.txt is dtP[4]
          unless found
            create_doc doc, ->
              console.log 'Doc created'
              cb()
          else
            console.log 'Doc found'
            cb()
    

    async.series jobs, -> process.nextTick -> callback()
  else
    console.log 'not SPLIT'
    my_doc = new Doc2
      sky_id: sky_doc.ID
      author: user._id
      touch: fb_date(sky_doc.DATA2, sky_doc.TIME2)
      dat: fb_date(sky_doc.DATA, sky_doc.TIME1)
      org: my_org._id
      tel: sky_doc.PHONES
      txt: txt
      who: sky_doc.SUBJECT
      sky_manager_id: sky_doc.MANAGER

    create_doc my_doc, -> process.nextTick ->
      console.log 'MY DOC saved'
      callback()

# Main process
proceed = (sky_doc, callback) ->
  console.log 'Proceed SKY DOC', sky_doc.ID
  my_getOrg sky_doc.NN2, (my_org) ->
    #console.log sky_doc
    my_getUser sky_doc.MANAGER, (user) ->
      process_doc sky_doc, user, my_org, -> process.nextTick -> callback()

process_all_fb_docs = ->
  now = conn.querySync('select count(*), max(ID), min(ID) from KONTAKTS').fetchSync(1, true).shift()
  #now = conn.querySync('select count(*), max(ID), min(ID) from KONTAKTS where NN2=500296').fetchSync(1, true).shift()
  nowID = now.MIN-1

  getNext = -> process.nextTick ->
    if nowID > now.MAX
      console.log 'DONE', nowID, now.MAX
      process.exit()
    if row = fb_fetchK nowID
      nowID = row.ID
      #proceed row, ->
      #  console.log 'DONE', nowID, now.MAX
      #  process.exit()
      proceed row, -> process.nextTick -> getNext()
    else
      console.log 'DOC DIE', ++nowID
      process.nextTick -> getNext()

  getNext()
  #dbg = fb_fetchOne 'select * from KONTAKTS where ID=25799'
  #dbg2 = fb_fetchOne 'select * from KONTAKTS where ID=25799'
  #proceed dbg, -> process.nextTick ->
  #  #process.exit()
  #  proceed dbg2, -> process.nextTick -> process.exit()

# HERE START
async.parallel([
  (cb) -> Org2.remove {}, cb
  (cb) -> Doc2.remove {}, cb
  (cb) -> Ppl2.remove {}, cb
], (err, res) ->
  Org2Schema = new Mongoose.Schema { touch: Date, name: String, addr: String, sky_id: Number }
  (new Org2({ name: 'ERT' })).save (err, res) ->
    ERTID = res._id
    process_all_fb_docs()
)
    
#Org2.remove {}, -> Doc2.remove {}, -> Ppl2.remove {}, ->
#  Org2Schema = new Mongoose.Schema { touch: Date, name: String, addr: String, sky_id: Number }
#  (new Org2({ name: 'ERT' })).save (err, res) ->
#    ERTID = res._id
#    process_all_fb_docs()
