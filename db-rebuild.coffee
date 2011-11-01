# Requires
Mongoose = require 'mongoose'
async = require 'async'
prm = require 'commander'
Buffer = require('buffer').Buffer
Iconv = require('iconv').Iconv
ProgressBar = require 'progress'
fb = require 'firebird' # FUCKED database

# Init
conn = Mongoose.connect 'mongodb://localhost/foo2'
{ Org2, Doc2, Ppl2 } = require './models'

conn = fb.createConnection()
conn.connectSync '10.96.0.162/3045/C:\\SKYAPM\\BIN\\BASE3.GDB', 'sysdba', 'fbclient.dll', ''
cnv = new Iconv 'CP1251', 'UTF-8'

prm
  .version('0.0.1')
  .option('-D, --clean-docs', 'Clean DOCs')
  .option('-O, --clean-orgs', 'Clean ORGs')
  .option('-P, --clean-ppls', 'Clean PPLs')
  .option('-c, --clean', 'Clean all tables in database')
  .option('-p, --ppls', 'Process PPLs')
  .option('-o, --orgs', 'Process PPLs')
  .option('-d, --docs', 'Process DOCs')
  .option('-s, --change-structure', 'Change database structure')
  .option('-i, --debug-info', 'Add debug info in database')
  .option('-g, --debug', 'Debug mode')
  .parse process.argv

ERTID = 0

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
    console.log '\nDIED', sql,'\n', e
    process.exit()

fb_fetchUser = (id) ->
  console.log 'fb_fetchUser', id if prm.debug
  fb_fetchOne "select FIRST 1 NAME, ID, DOLZHN from WORKS where ID = #{id}"

# FUCK FUCK FUCK FUCK
fb_getOrgByEachField = (id) ->
  fields = 'NN2, FULLNAME, URL, INN, ZIP, STITLE, HOUSE, LITER, OFFICE, EXTEND, ACITY, AADDR, OBL, APHONE, ATCOD'.split ', '
  ret = {}
  fields.map (f) ->
    ret[f] = (fb_fetchOne "select FIRST 1 #{f} from ENPRISE where NN2=#{id}")[f]
  ret
  
fb_getOrg = (id) ->
  console.log 'fb_org', id if prm.debug
  sql =  "select FIRST 1 * from ENPRISE where NN2 = #{id}"
  try
    return conn.querySync(sql).fetchSync(1, true).shift()
  catch e
    fb_getOrgByEachField id

# MY find or create user
my_getUser = (sky_user_id, callback) ->
  console.log 'Proceed find MY USER', sky_user_id if prm.debug
  Ppl2.find({ sky_id: sky_user_id, org: ERTID }).limit(1).execFind (err, my_user) ->
    if my_user.length isnt 0
      o = my_user.shift()
      console.log 'MY user found' if prm.debug
      callback o
    else
      sky_user = fb_fetchUser sky_user_id
      (new Ppl2({ sky_id: sky_user.ID, org: ERTID, name: sky_user.NAME, post: sky_user.DOLZHN })).save (err, res) ->
        console.log 'My USER created', res.name if prm.debug
        callback res
      
# MY find or create org
my_getOrg = (sky_org_id, callback) ->
  console.log 'Proceed find MY ORG', sky_org_id if prm.debug
  Org2.find({ sky_id: sky_org_id }).limit(1).execFind (err, my_org) ->
    if my_org.length isnt 0
      o = my_org.shift()
      console.log 'MY org found', o.name if prm.debug
      callback o
    else
      sky_org = fb_getOrg sky_org_id
      #sky_org = fb_getOrgByEachField sky_org_id
      console.log 'get SKY ORG', sky_org if prm.debug

      org = new Org2
        name: sky_org.FULLNAME
        sky_id: sky_org.NN2
        url: sky_org.URL
        inn: sky_org.INN
        xAddr:
          zip: sky_org.ZIP
          street: sky_org.STITLE
          house: sky_org.HOUSE
          liter: sky_org.LITER
          office: sky_org.OFFICE
          ext: sky_org.EXTEND
          city: sky_org.ACITY
          addr: sky_org.AADDR
          obl: sky_org.OBL
        phone: sky_org.APHONE
        pCode: sky_org.ATCOD

      org.save (err, res) ->
        console.log 'MY ORG created', org.name if prm.debug
        callback res

# FB doc + time -> doc.time
fb_date = (dat, tim) ->
  [p_dat, p_tim] = [new Date(dat), new Date(tim)]
  d = new Date p_dat.getFullYear(), p_dat.getMonth(), p_dat.getDate()-1, p_tim.getHours()+1, p_tim.getMinutes(), p_tim.getSeconds()

create_doc = (doc, callback) ->
  (new Doc2(doc)).save (err, res) ->
    callback res

my_getDoc = (sky_org_id, callback) -> Doc2.find({ sky_org_id: sky_org_id }).execFind (err,res) -> callback res


process_doc = (sky_doc, user, my_org, callback) ->
  txt = fb_getTxt sky_doc.TXT
  #console.log 'TXTALL\n', txt, '\nEND-OF-TXTALL'
  tF = txt.match /\s*(\d+\D\d+\D\d+.+)/mg
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
      dtP = t.match /^\s*(\d+)\D(\d+)\D(\d+)\s*(.+)$/
      dtP[3] = '20'+dtP[3] if String(dtP[3]).length is 2
      dt = new Date dtP[3]*1, dtP[2]*1, dtP[1]*1+1, -19 # WTF? -19 hours?
      dt = fb_date(sky_doc.DATA2, sky_doc.TIME2) if dt > fb_date(sky_doc.DATA2, sky_doc.TIME2)
      doc =
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

      if prm.debugInfo
        doc.dbg = t
        doc.dbg2 = txt

      jobs.push (cb) ->
        my_getDoc sky_doc.NN2, (fnd_docs) ->
          found = false
          fnd_docs.map (d) -> found = true if d.txt is dtP[4]
          unless found
            create_doc doc, ->
              console.log 'Doc created' if prm.debug
              cb()
          else
            console.log 'Doc found' if prm.debug
            cb()
    

    async.series jobs, -> process.nextTick -> callback()
  else
    console.log 'not SPLIT' if prm.debug
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
      console.log 'MY DOC saved' if prm.debug
      callback()

# MY find or create Ppl
my_getCreatePpl = (sky_ppl, my_org, callback) ->
  console.log 'Proceed find MY PPL', sky_ppl.ID if prm.debug

  Ppl2.findOne({ sky_id: sky_ppl.ID }).execFind (err, my_ppl) ->
    if my_ppl.length > 0
      console.log 'MY ppl found' if prm.debug
      callback my_ppl
    else
      (new Ppl2({ sky_id: sky_ppl.ID, org: my_org._id, name: sky_ppl.NAME, post: sky_ppl.DOLZHN, tel: "#{sky_ppl.PHONE}##{sky_ppl.SOTKA}" })).save (err, res) ->
        console.log 'My PPL created', res.name if prm.debug
        callback res

proceedPpl = (sky_ppl, callback) ->
  console.log 'Process SKY PPLS', sky_ppl.ID if prm.debug
  my_getOrg sky_ppl.NN2, (org) ->
    my_getCreatePpl sky_ppl, org, ->
      callback()

proceedOrg = (sky_org, callback) ->
  console.log 'Proceed SKY ORG', sky_org.ID if prm.debug
  my_getOrg sky_org.NN2, -> process.nextTick -> callback()

proceedDoc = (sky_doc, callback) ->
  console.log 'Proceed SKY DOC', sky_doc.ID if prm.debug
  my_getOrg sky_doc.NN2, (my_org) ->
    #console.log sky_doc
    my_getUser sky_doc.MANAGER, (user) ->
      process_doc sky_doc, user, my_org, -> process.nextTick -> callback()

fucked_fb_cycle = (sql_table, id, fields, fun, callback) ->
  console.log "select count(*), max(#{id}), min(#{id}) from #{sql_table}" if prm.debug
  now = conn.querySync("select count(*), max(#{id}), min(#{id}) from #{sql_table}").fetchSync(1, true).shift()
  nowID = now.MIN - 1
  console.log 'now', now if prm.debug
  #nowID = now.MAX - 5
  
  bar = new ProgressBar 'parsing [:bar] :percent :etas', { total: now.COUNT, incomplete: ' ', complete: '.',  width: 80 } unless prm.debug

  getNext = -> process.nextTick ->
    bar.tick() unless prm.debug
    if nowID > now.MAX
      console.log 'DONE', nowID, now.MAX if prm.debug
      callback()
    else
      console.log "select FIRST 1 * from #{sql_table} where #{id} > #{nowID} ORDER BY #{id}" if prm.debug
      if row = fb_fetchOne "select FIRST 1 #{fields} from #{sql_table} where #{id} > #{nowID} ORDER BY #{id}"
        nowID = row[id]
        fun row, -> process.nextTick -> getNext()
      else
        nowID++
        console.log 'DOC DIE' if prm.debug
        process.nextTick -> getNext()

  getNext()

exitAtLast = ->
  console.log '\nDONE' if prm.debug
  Mongoose.disconnect()
  process.exit()

# HERE START
jobs = [
  (cb) ->
    if prm.cleanOrgs or prm.clean
      Org2.remove {}, -> cb console.log 'Clean ORGs done'
    else cb()
  (cb) ->
    if prm.cleanDocs or prm.clean
      Doc2.remove {}, -> cb console.log 'Clean DOCs done'
    else cb()
  (cb) ->
    if prm.cleanPpls or prm.clean
      Ppl2.remove {}, -> cb console.log 'Clean PPLs done'
    else cb()
]

if prm.changeStructure
  console.log 'change structure'
  # change all varchar fields to 250 length. as a said - FUCKFUCKCUFKCUXKCUFKC UFCK
  fb_changeFields = "
    select f.rdb$relation_name, f.rdb$field_name, V.RDB$FIELD_LENGTH
    from rdb$relation_fields f
    join rdb$relations r on f.rdb$relation_name = r.rdb$relation_name
    JOIN RDB$FIELDS V ON F.RDB$FIELD_SOURCE = V.RDB$FIELD_NAME
    and r.rdb$view_blr is null
    AND V.RDB$FIELD_TYPE = 37
    and V.RDB$FIELD_LENGTH < 199
    AND F.RDB$RELATION_NAME != 'PARAMS'
    AND F.RDB$RELATION_NAME != 'USER_LOGIN'
    and (r.rdb$system_flag is null or r.rdb$system_flag = 0)
    order by 1, f.rdb$field_position;
    "
  resF =  conn.querySync(fb_changeFields).fetchSync('all', true)
  resF.map (a) ->
    console.log a.RDB$RELATION_NAME, a.RDB$FIELD_NAME, a.RDB$FIELD_LENGTH
    ret = conn.querySync "ALTER TABLE #{a.RDB$RELATION_NAME} ALTER COLUMN #{a.RDB$FIELD_NAME} TYPE VARCHAR(199)"
    ret = conn.querySync "COMMIT"

async.parallel jobs, (err, res) ->
  Org2Schema = new Mongoose.Schema { touch: Date, name: String, addr: String, sky_id: Number }
  (new Org2({ name: 'ERT' })).save (err, res) ->
    ERTID = res._id

    jobs = [
      (cb) ->
        if prm.orgs
          console.log 'Processing orgs'
          fucked_fb_cycle 'ENPRISE', 'NN2', 'NN2', proceedOrg, -> cb()
        else cb()
      (cb) ->
        if prm.ppls
          console.log 'Processing ppls'
          fucked_fb_cycle 'PHONEBOOK', 'ID', '*', proceedPpl, -> cb()
        else cb()
      (cb) ->
        if prm.docs
          console.log 'Processing docs'
          fucked_fb_cycle 'KONTAKTS', 'ID', '*', proceedDoc, -> cb()
        else cb()
    ]

    async.series jobs, (err, res) -> exitAtLast()
