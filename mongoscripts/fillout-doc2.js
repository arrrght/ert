var db = db.getSisterDB('foo2');
db.doc2s.drop();
db.org2s.drop();
//db.ppl2s.drop();

var c1 = db.z_kontakts.find();
while(c1.hasNext()){
  var i = c1.next();
  
  var org = db.org2s.findOne({ sky_id: i.NN2 });
  if(!org){
    sky_org = db.z_enprise.findOne({ NN2: i.NN2 });
    db.org2s.save({ name: sky_org.FULLNAME, sky_id: i.NN2 });
    org = db.org2s.findOne({ sky_id: i.NN2 });
  };

  var I = {
    dat: new Date(Date(i.data + ' ' + i.time1 + ' +0500')),
    org: org._id,
    tel: 'xUnknown',
    txt: i.TXT + ' [' + i.RESULTINFO + ']',
    who: i.SUBJECT,
    sky_manager_id: i.MANAGER
  };

/*
  var bName = db.tBrands.findOne({ id: item.brand_id }).name;
  var rimT = db.tRim.findOne({ id: item.rim_id });
  var rim = rimT ? rimT.name : null;
  var nameT = db.tCat.findOne({ id: item.top });
  var name = nameT ? nameT.name : null;
  var tp = nameT && nameT.tp==0 ? 'R' : '-';
  var nItem = {
    brand: bName,
    name: name,
    posD: rim,
    hS: item.size,
    tType: item.type,
    lay: item.pr,
    tra: item.tra,
    d: item.diameter,
    s: item.width,
    tp: tp,
		sizeName: '' + item.size + tp + rim
  };
*/
  db.doc2s.save(I);
  //print('.');
  print('name: ' + I.dat + ', datA: ' + I.datA + ', id: ' + I.who);
};
