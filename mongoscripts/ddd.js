var db = db.getSisterDB('foo');
db.teches.drop();

var row2, row3, row4;
function getType(row){
	function nu(){ return { name: 'unknown', value: null }}

	if (row.top == 0){
		return { name: 'brand', value: row }
	}else{
		row2 = db.tSpec.findOne({ id: row.top });
		if (!row2){ return nu() };
		if (row2.top == 0){
			return { name: 'type', value: row2 };
		}else{
			row3 = db.tSpec.findOne({ id: row2.top });
			if (!row3){ return nu() };
			if (row3.top == 0){
				return { name: 'name', value: row3 };
			}else{
				row4 = db.tSpec.findOne({ id: row3.top });
				if (!row4) { return nu(); };
				return { name: 'size', value: row4 }
			}
		}
	}
}

var c1 = db.tSpec.find();
var cnt = 0;
while(c1.hasNext()){
	cnt++;
	var item = c1.next();
	var res = getType(item);
	if (res.value){
		if (res.name == 'name'){
			var name = item.name;
			var typeI = db.tSpec.findOne({ id: item.top });
			var type = typeI ? typeI.rname : null;
			var brandI = db.tSpec.findOne({ id: typeI.top });
			var brand = brandI ? brandI.name : null;
			var sizesI = db.tSpec.find({ top: item.id });
			var sizes = [];
			while(sizesI.hasNext()){
				sizes.push(sizesI.next().size);
			}
			
			//item.anons = item.anons.replace(/,/g,'');
			db.teches.save({
				typ: type,
				brand: brand,
				name: name,
				sizes: item.anons
				//sizes: sizes.join(' ')
			});
			print (cnt + ' ' + item.id + ' name: ' + name + ' type: ' + type + ' brand: ' + brand + ' sizes: ' + sizes);
		}
	}
}
