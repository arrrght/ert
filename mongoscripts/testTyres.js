var db = db.getSisterDB('foo');

Array.prototype.unique =
  function() {
    var a = [];
    var l = this.length;
    for(var i=0; i<l; i++) {
      for(var j=i+1; j<l; j++) {
        // If this[i] is found later in the array
        if (this[i] === this[j])
          j = ++i;
      }
      a.push(this[i]);
    }
    return a;
  };


var c1 = db.tyres.find();
var hS = {};

while(c1.hasNext()){
	var i = c1.next();
	var n = i.hS;
	n = n.replace(/^ */,'');

	if (!hS[n]){ hS[n] = []; }
	hS[n].push(i.posD);
	hS[n] = hS[n].unique();
}

for(var i in hS){
	if (hS[i].length>1){
		print(i + ' --> ' + hS[i]);
	}
}
