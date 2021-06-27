class_name Person
extends Node
# giving type cause person might be from saved file.
enum pType {
	WRONG = -2,
	FIT = -1,
	BROKEN,
}
var rnd: RandomNumberGenerator = RandomNumberGenerator.new()
var f = {}
var face = []
var height: float
var weight: float
var age: int
var job: String
var education: String
var distance: float
var likes = []
var dislikes = []
var ceils = {"height": 200, "weight": 150, "distance": 1000, "age": 100}
var floors = {"height": 150, "weight": 45, "distance": 10, "age": 18}
var distance_units: String
var height_units: String
var weight_units: String
var glasses: bool = false
var type: int = 0
var writen:bool = false
var text:String = ""


func _ready():
	rnd.randomize()
	f["gender"] = rnd.randi() % 2 == 0
	f["nam"] = (
		Info.names_male[rnd.randi_range(0, Info.names_male.size() - 1)]
		if (f.get("gender"))
		else Info.names_female[rnd.randi_range(0, Info.names_female.size() - 1)]
	)
	f["age"] = rnd.randi_range(18, 100)
	rnd.randomize()
	if rnd.randi_range(0, 27) != 27:
		f["workProfession"] = Info.jobs[rnd.randi_range(0, Info.jobs.size() - 1)]
		f["workPlace"] = Info.companies[rnd.randi_range(0, Info.companies.size() - 1)]
	else:
		f["workProfession"] = "unemployed"
		f["workPlace"] = ""

	var edu_type = rnd.randi_range(0, 2)
	f["education_place"] = ("School" \
		if edu_type == 0 \
		else ("College" if edu_type == 1 \
		else "University")
	)
	f["educationTown"] = Info.cities[rnd.randi_range(0, Info.cities.size() - 1)]

	f["distance"] = rnd.randi_range(10, 1000)

	rnd.randomize()
	var likes_num = create_preferences()
	var dislikes_num = create_preferences()
	for i in likes_num:
		likes.append(
			Info.items[i] if i < Info.items.size() else Info.actions[i - Info.items.size()]
		)
	for i in likes_num:
		dislikes_num.erase(i)
	rnd.randomize()
	f["height"] = rnd.randi_range(150, 200)
	for i in dislikes_num:
		dislikes.append(
			Info.items[i] if i < Info.items.size() else Info.actions[i - Info.items.size()]
		)
	f["weight"] = float(rnd.randi_range(4500, 15000)) / 100
	face.append(rnd.randi_range(1, 12))  #eyes.
	face.append(rnd.randi_range(1, 12))  #nose.
	face.append(rnd.randi_range(1, 12))  #mouth.
	face.append(rnd.randi_range(1, 10))  #hair.
	face.append(rnd.randi_range(0, 3))  #background.


# giving type cause person might be from saved file.
func initialize(typeGiven: int, reqArr: Array) -> void:
	self.type = typeGiven
	match type:
		pType.WRONG:
			# check all requests.
			for i in reqArr.size():
				if check(i):
					type = pType.FIT
		pType.FIT:
			make_fit(reqArr[rnd.randi_range(0, reqArr.size())])
		_:
			make_broken()


func writed() -> void:
	if writen:
		return
	writen = true
	job = f.get("workProfession") + ", " + f.get("workPlace")
	education = (
		(f.get("education_place") + " of " + f.get("educationTown"))
		if chance()
		else (f.get("educationTown") + " " + f.get("education_place"))
	)
	if chance():
		distance_units = "m"
		distance = f.get("distance")
	else:
		distance_units = "km"
		distance = float(f.get("distance")) / 1000
	if chance():
		height = float(f.get("height")) / 100
		height_units = "m"
	else:
		height = f.get("height")
		height_units = "cm"
	if chance():
		weight = float(f.get("weight")) / 100
		weight_units = "q"
	else:
		weight_units = "kg"
		weight = f.get("weight")


# 50/50 chance of true and false respectively.
func chance() -> bool:
	return rnd.randi_range(1, 100) <= 50


func check(r) -> int:
	for i in r.f.keys():
		if r.comp.has(i + "Comp"):
			var res = check_compare(i, r)
			if ! res:
				return pType.WRONG
		elif r.f.get(i) != f.get(i):
			return pType.WRONG
	return pType.FIT


func make_fit(r) -> void:
	type = pType.FIT
	for i in r.f.keys():
		if r.comp.has(i + "Comp"):
			# 0 =, 1 >, 2 <
			match r.comp.get(i + "Comp"):
				0:
					f[i] = r.f.get(i)
				1:
					f[i] = rnd.randi_range(r.f.get(i) + 1, ceils.get(i))
				2:
					f[i] = rnd.randi_range(floors.get(i), r.f.get(i) - 1)
		else:
			f[i] = r.f.get(i)
	for i in r.likes:
		dislikes.erase(i)
		likes.append(i)
	for i in r.dislikes:
		likes.erase(i)
		dislikes.append(i)


func make_broken() -> void:
	type = rnd.randi_range(0, 10)
	match type:
		0:
			face[rnd.randi_range(0, 2)] = 0
		1:
			f["nam"] = rand_string()
		2:
			f["age"] = -f["age"]
		3:
			f["workProfession"] = rand_string()
		4:
			f["workPlace"] = rand_string()
		5:
			f["educationTown"] = rand_string()
		6:
			f["distance"] = -f["distance"]
		7:
			if likes.size() == 0:
				likes.append(rand_string())
			else:
				likes[rnd.randi_range(0, likes.size() - 1)] = rand_string()
		8:
			if dislikes.size() == 0:
				dislikes.append(rand_string())
			else:
				dislikes[rnd.randi_range(0, dislikes.size() - 1)] = rand_string()
		9:
			f["height"] = -f["height"]
		10:
			f["weight"] = -f["weight"]


# creates random string from unused anywhere else symbols.
func rand_string() -> String:
	var nonLetter = rnd.randi_range(91, 95)
	var res = ""
	for i in rnd.randi_range(4, 8):
		res += char(rnd.randi_range(65, 122))
	res[rnd.randi_range(0, res.length() - 1)] = nonLetter
	return res


func check_compare(par, r) -> bool:
	match r.comp.get(par + "Comp"):
		0:
			if f.get(par) != r.f.get(par):
				return false
		1:
			if f.get(par) <= r.f.get(par):
				return false
		2:
			if f.get(par) >= r.f.get(par):
				return false
	return true


# creates sentences from interests array.
func interests_text() -> String:
	if text != "":
		return text
	text = ""
	for i in likes:
		text += "  "
		text += Info.likes[rnd.randi_range(0, Info.likes.size() - 1)]
		text = text.replace("@", str(i))
		text += "\n"
	text += "\n"
	for i in dislikes:
		text += "  "
		text += Info.dislikes[rnd.randi_range(0, Info.likes.size() - 1)]
		text = text.replace("@", i)
		text += "\n"
	text.erase(text.length() - 1, 1)
	return text


# creates likes or dislikes array.
func create_preferences() -> Array:
	var arr = []
	for i in rnd.randi_range(1, 2):
		var element = rnd.randi_range(0, Info.items.size() + Info.actions.size() - 1)
		element = get_unique_element(arr, element)
		arr.append(element)
	return arr


# reqursively returns unique element that is not in given array.
func get_unique_element(arr, elem):
	for j in arr.size():
		if arr[j] == elem:
			return get_unique_element(arr, (elem + 1) % (Info.items.size() + Info.actions.size() - 1))
	return elem


func destroy():
	queue_free()
