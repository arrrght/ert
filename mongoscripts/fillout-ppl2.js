var db = db.getSisterDB('foo');
db.tyres.drop();

var c1 = db.tCat.find();
while(c1.hasNext()){
  var item = c1.next();
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
  db.tyres.save(nItem);
  print('name: ' + nItem.name + ', id: ' + item.id );
};
