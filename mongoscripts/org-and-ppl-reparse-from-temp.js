// vim: foldenable:foldmethod=marker
// need underscore. run with "./underscore.js ./my-script.js"
var db = db.getSisterDB('foo');
var cnt = 0;
db.ppls.drop();
db.orgs.drop();
db.province.drop();
db.obl.drop();

// Округ Table OKRUG {{{
var _area = [
	'Центральный федеральный округ',
	'Северо-Западный федеральный округ',
	'Южный федеральный округ',
	'Приволжский федеральный округ',
	'Уральский федеральный округ',
	'Сибирский федеральный округ',
	'Дальневосточный федеральный округ',
	'Казахстан',
	'Украина',
];
// }}}
// Область {{{
var _province = [
	{ province: 1, title: 'Свердловская', area: 5 },
	{ province: 3, title: 'Тюменская', area: 5 },
	{ province: 2, title: 'Челябинская', area: 5 },
	{ province: 102, title: 'Брянская область', area: 1 },
	{ province: 103, title: 'Владимирская область', area: 1 },
	{ province: 104, title: 'Воронежская область', area: 1 },
	{ province: 101, title: 'Белгородская область', area: 1 },
	{ province: 105, title: 'Ивановская область', area: 1 },
	{ province: 106, title: 'Калужская область', area: 1 },
	{ province: 107, title: 'Костромская область', area: 1 },
	{ province: 108, title: 'Курская область', area: 1 },
	{ province: 109, title: 'Липецкая область', area: 1 },
	{ province: 111, title: 'Орловская область', area: 1 },
	{ province: 112, title: 'Рязанская область', area: 1 },
	{ province: 113, title: 'Смоленская область', area: 1 },
	{ province: 110, title: 'Московская область', area: 1 },
	{ province: 114, title: 'Тамбовская область', area: 1 },
	{ province: 115, title: 'Тверская область', area: 1 },
	{ province: 117, title: 'Ярославская область', area: 1 },
	{ province: 119, title: 'Вологодская область', area: 2 },
	{ province: 120, title: 'Калининградская область', area: 2 },
	{ province: 116, title: 'Тульская область', area: 1 },
	{ province: 123, title: 'Ленинградская область', area: 2 },
	{ province: 118, title: 'Архангельская область', area: 2 },
	{ province: 125, title: 'Ненецкий автономный округ', area: 2 },
	{ province: 126, title: 'Новгородская область', area: 2 },
	{ province: 121, title: 'Республика Карелия', area: 2 },
	{ province: 122, title: 'Республика Коми', area: 2 },
	{ province: 127, title: 'Псковская область', area: 2 },
	{ province: 124, title: 'Мурманская область', area: 2 },
	{ province: 128, title: 'Республика Адыгея', area: 3 },
	{ province: 129, title: 'Астраханская область', area: 3 },
	{ province: 130, title: 'Волгоградская область', area: 3 },
	{ province: 131, title: 'Республика Дагестан', area: 3 },
	{ province: 132, title: 'Республика Ингушетия', area: 3 },
	{ province: 133, title: 'Кабардино-Балкарская Республика', area: 3 },
	{ province: 134, title: 'Республика Калмыкия', area: 3 },
	{ province: 135, title: 'Карачаево-Черкесская Республика', area: 3 },
	{ province: 136, title: 'Краснодарский край', area: 3 },
	{ province: 138, title: 'Республика Северная Осетия-Алания', area: 3 },
	{ province: 140, title: 'Чеченская Республика', area: 3 },
	{ province: 142, title: 'Кировская область', area: 4 },
	{ province: 137, title: 'Ростовская область', area: 3 },
	{ province: 143, title: 'Республика Марий Эл', area: 4 },
	{ province: 139, title: 'Ставропольский край', area: 3 },
	{ province: 144, title: 'Республика Мордовия', area: 4 },
	{ province: 141, title: 'Республика Башкортостан', area: 4 },
	{ province: 145, title: 'Нижегородская область', area: 4 },
	{ province: 147, title: 'Пензенская область', area: 4 },
	{ province: 149, title: 'Самарская область', area: 4 },
	{ province: 150, title: 'Саратовская область', area: 4 },
	{ province: 146, title: 'Оренбургская область', area: 4 },
	{ province: 151, title: 'Республика Татарстан', area: 4 },
	{ province: 148, title: 'Пермский край', area: 4 },
	{ province: 152, title: 'Удмуртская Республика', area: 4 },
	{ province: 153, title: 'Ульяновская область', area: 4 },
	{ province: 154, title: 'Чувашская Республика', area: 4 },
	{ province: 155, title: 'Курганская область', area: 5 },
	{ province: 158, title: 'Ханты-Мансийский автономный округ - Югра', area: 5 },
	{ province: 160, title: 'Ямало-Ненецкий автономный округ', area: 5 },
	{ province: 161, title: 'Республика Алтай', area: 6 },
	{ province: 171, title: 'Республика Тыва', area: 6 },
	{ province: 173, title: 'Амурская область', area: 7 },
	{ province: 174, title: 'Еврейская автономная область', area: 7 },
	{ province: 162, title: 'Алтайский край', area: 6 },
	{ province: 163, title: 'Республика Бурятия', area: 6 },
	{ province: 164, title: 'Забайкальский край', area: 6 },
	{ province: 165, title: 'Иркутская область', area: 6 },
	{ province: 166, title: 'Кемеровская область', area: 6 },
	{ province: 167, title: 'Красноярский край', area: 6 },
	{ province: 168, title: 'Новосибирская область', area: 6 },
	{ province: 169, title: 'Омская область', area: 6 },
	{ province: 170, title: 'Томская область', area: 6 },
	{ province: 177, title: 'Приморский край', area: 7 },
	{ province: 172, title: 'Республика Хакасия', area: 6 },
	{ province: 178, title: 'Сахалинская область', area: 7 },
	{ province: 197, title: 'Полтавская', area: 9 },
	{ province: 175, title: 'Камчатский край', area: 7 },
	{ province: 176, title: 'Магаданская область', area: 7 },
	{ province: 179, title: 'Хабаровский край', area: 7 },
	{ province: 180, title: 'Чукотский автономный округ', area: 7 },
	{ province: 181, title: 'Республика Саха (Якутия)', area: 7 },
	{ province: 183, title: 'Акмолинская область', area: 8 },
	{ province: 184, title: 'Актюбинская область', area: 8 },
	{ province: 185, title: 'Алматинская область', area: 8 },
	{ province: 186, title: 'Атырауская область', area: 8 },
	{ province: 187, title: 'Восточно-казахстанская область', area: 8 },
	{ province: 188, title: 'Жамбылская область', area: 8 },
	{ province: 189, title: 'Западно-казахстанская область', area: 8 },
	{ province: 190, title: 'Карагандинская область', area: 8 },
	{ province: 191, title: 'Костанайская область', area: 8 },
	{ province: 192, title: 'Казылординская область', area: 8 },
	{ province: 193, title: 'Мангистауская область', area: 8 },
	{ province: 194, title: 'Павлодарская область', area: 8 },
	{ province: 195, title: 'Северо-казахстанская область', area: 8 },
	{ province: 196, title: 'Южно-казахстанская область', area: 8 }
];
// }}}

_province.forEach(function(i){
	db.province.save(i);
});

// tOrgs -> ENPRISE
var c = db.tOrgs.find();
while(c.hasNext()){
	var i = c.next();
	var province = db.province.findOne({ province: i.OBL});
	var flds = {
		oldId: i.NN2,
		name: i.FULLNAME,
		// округ
		area: province ? _area[province.area-1] : null,
		// область
		province: province ? province.title : null,
		city: i.ACITY,
		zip: i.ZIP,
		street: i.STITLE,
		house: i.HOUSE,
		liter: i.LITER,
		office: i.OFFICE,
		addr: i.AADDR,
		rem: '- пока не используется -',
		// not used yet
		www: i.URL,
		// форма собственности
		fs: i.EPF,
		// ИНН
		inn: i.INN,
		addr_add: i.EXTEND,
		phone: i.APHONE,
		// КПП
		kpp: i.KPP
	};
	db.orgs.save(flds);
	cnt ++;
	//print('org:' + flds.name);
}
print(cnt + ' orgs saved'); cnt = 0;

// Now ppl
var c1 = db.tOrgs.find();
while(c1.hasNext()){
  var i = c1.next();
	var org = db.orgs.findOne({ oldId: i.NN2 });
	var orgId = org? org._id : null;
	var contacts = [];
	var flds = {
		fio_fam: i.DIRECTOR,
		fio_nam: null,
		fio_oth: null,
		post: 'Директор',
		orgName: i.FULLNAME,
		orgOldId: i.NN2,
		orgId: orgId,
		contacts: contacts
	};
	if (flds.orgId){
		db.ppls.save(flds);
		cnt ++;
	}
};
print (cnt + ' ppl saved'); cnt = 0;

function addOrNot(record, contacts, oldName, newName){
	if (record[oldName]){
		contacts.push({ cntType: newName, cnt: record[oldName] });
	}
	return contacts;
}

// tPhones -> PHONEBOOK
var c1 = db.tPhones.find();
while(c1.hasNext()){
  var i = c1.next();
	var org = db.orgs.findOne({ oldId: i.NN2 });
	var orgId = org? org._id : null;
	var contacts = [];

	contacts = addOrNot(i, contacts, 'PHONE', 'Рабочий телефон');
	contacts = addOrNot(i, contacts, 'EMAIL', 'Email');
	contacts = addOrNot(i, contacts, 'SOTKA', 'Сотовый телефон');

	var flds = {
		fio_fam: i.NAME,
		fio_nam: null,
		fio_oth: null,
		post: i.DOLZHN,
		orgName: i.ORGANIZ,
		orgOldId: i.NN2,
		orgId: orgId,
		contacts: contacts
	};
	if (flds.orgId && flds.fio_fam && flds.fio_fam.length>1){
		db.ppls.save(flds);
		cnt ++;
		//print(contacts);
		/*
		print(
			'fio:' + flds.fio +
			' post:' + flds.post +
			' orgName:' + flds.orgName +
			' orgOldId:' + flds.orgOldId +
			' orgId:' + orgId
		);
		*/
	}
};
print (cnt + ' ppl saved');
