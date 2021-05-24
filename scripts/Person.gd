class_name Person
extends Node
var rnd:RandomNumberGenerator = RandomNumberGenerator.new()
var f = {}
var face = []
var height:float
var weight:float
var age:int
var job:String
var education:String
var distance:float
var likes = []
var dislikes = []
var ceils = {"height":200,"weight":150,"distance":1000,"age":100}
var floors = {"height":150,"weight":45,"distance":10,"age":18}
var distanceUnits:String
var heightUnits:String
var weightUnits:String
var glasses:bool = false
var type:int = 0

enum pType{
	WRONG = -2,
	FIT = -1,
	BROKEN,
}


func _ready():
	rnd.randomize()
	f["gender"] = rnd.randi() % 2 == 0
	f["nam"] = Info.namesMale[rnd.randi_range(
		0, Info.namesMale.size()-1)] if (
		f.get("gender")) else Info.namesFemale[rnd.randi_range(
		0, Info.namesFemale.size()-1)]
	f["age"] = rnd.randi_range(18, 100)
	rnd.randomize()
	if rnd.randi_range(0, 27) != 27:
		f["workProfession"] = Info.jobs[rnd.randi_range(0, Info.jobs.size()-1)]
		f["workPlace"] =  Info.companies[rnd.randi_range(
			0, Info.companies.size()-1)]
	else:
		f["workProfession"] = "unemployed"
		f["workPlace"] = ""

	var eduType = rnd.randi_range(0, 2)
	f["educationPlace"] = "School" if eduType == 0 else (
		"College" if eduType == 1 else "University")
	f["educationTown"] = Info.cities[rnd.randi_range(0, Info.cities.size()-1)]

	f["distance"] = rnd.randi_range(10, 1000)

	rnd.randomize()
	var likesNum = createPreferences()
	var dislikesNum = createPreferences()
	for i in likesNum:
		likes.append(Info.items[i
		] if i < Info.items.size() else Info.actions[i - Info.items.size()])
	for i in likesNum:
		dislikesNum.erase(i)
	rnd.randomize()
	f["height"] = rnd.randi_range(150, 200)
	for i in dislikesNum:
		dislikes.append(Info.items[i
		] if i < Info.items.size() else Info.actions[i - Info.items.size()])
	f["weight"] = float(rnd.randi_range(4500, 15000))/100
	face.append(rnd.randi_range(1, 12)) #eyes.
	face.append(rnd.randi_range(1, 12)) #nose.
	face.append(rnd.randi_range(1, 12)) #mouth.
	face.append(rnd.randi_range(1, 10)) #hair.
	face.append(rnd.randi_range(0, 3)) #background.
	if rnd.randi_range(0, 9) == 7:
		glasses = true
		face.append(rnd.randi_range(0,3))

# giving type cause person might be from saved file.
func initialize(typeGiven:int, reqArr:Array):
	self.type = typeGiven
	match type:
		pType.WRONG:
		# check all requests.
			for i in reqArr.size():
				if check(i):
					type = pType.FIT
		pType.FIT:
			makeFit(reqArr[rnd.randi_range(0, reqArr.size())])
		_:
			makeBroken()


func writed():
	job = f.get("workProfession") + ", " + f.get("workPlace")
	education = (f.get("educationPlace") + " of " + f.get("educationTown")
	) if chance() else (f.get("educationTown") + " " + f.get(
		"educationPlace"))
	if chance():
		distanceUnits = "m"
		distance = f.get("distance")
	else:
		distanceUnits = "km"
		distance = float(f.get("distance")) / 1000
	if chance():
		height = float(f.get("height")) / 100
		heightUnits = "m"
	else:
		height = f.get("height")
		heightUnits = "cm"
	if chance():
		weight = float(f.get("weight")) / 100
		weightUnits = "q"
	else:
		weightUnits = "kg"
		weight = f.get("weight")

# 50/50 chance of true and false respectively.
func chance() -> bool:
	return rnd.randi_range(1, 100) <= 50


func check(r) -> bool:
	for i in r.f.keys():
		if r.comp.has(i+"Comp"):
			var res = checkCompare(i, r)
			if !res:
				return false;
		elif r.f.get(i) != f.get(i):
			return false
	return true


func makeFit(r):
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
# Won't work with many values in r.likes (more than one)
	for i in r.likes:
		if !likes.has(i):
			if likes.size() == 0:
				likes.append(i)
			else:
				likes[rnd.randi_range(0, likes.size() - 1)] = i
# erasing dislikes that are the same to needed likes
		dislikes.erase(i)
	for i in r.dislikes:
		if !dislikes.has(i):
			if dislikes.size() == 0:
				dislikes.append(i)
			else:
				dislikes[rnd.randi_range(0, dislikes.size() - 1)] = i
		likes.erase(i)


func makeBroken():
	type = rnd.randi_range(0, 10)
	match type:
		0:
			face[rnd.randi_range(0, 2)] = 0
		1:
			f["nam"] = randString()
		2:
			f["age"] = -f["age"]
		3:
			f["workProfession"] = randString()
		4:
			f["workPlace"] = randString()
		5:
			f["educationTown"] = randString()
		6:
			f["distance"] = -f["distance"]
		7:
			if likes.size() == 0:
				likes.append(randString())
			else:
				likes[rnd.randi_range(0, likes.size() - 1)] = randString()
		8:
			if dislikes.size() == 0:
				dislikes.append(randString())
			else:
				dislikes[rnd.randi_range(0, dislikes.size() - 1)] = randString()
		9:
			f["height"] = -f["height"]
		10:
			f["weight"] = -f["weight"]

# creates random string from unused anywhere else symbols.
func randString() -> String:
	var nonLetter = rnd.randi_range(91, 95)
	var res = ""
	for i in rnd.randi_range(4, 8):
		res += char(rnd.randi_range(65,122))
	res[rnd.randi_range(0, res.length()-1)] = nonLetter
	return res


func checkCompare(par, r) -> bool:
	match r.comp.get(par+"Comp"):
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
func interestsText() -> String:
	var text = ""
	for i in likes:
		text += "  "
		text += Info.likes[rnd.randi_range(0, Info.likes.size()-1)]
		text = text.replace("@", str(i))
		text += "\n"
	text += "\n"
	for i in dislikes:
		text += "  "
		text += Info.dislikes[rnd.randi_range(0, Info.likes.size()-1)]
		text = text.replace("@", i)
		text += "\n"
	text.erase(text.length()-1, 1)
	return text

# creates likes or dislikes array.
func createPreferences():
	var arr = []
	for i in rnd.randi_range(1, 2):
		var newElement = rnd.randi_range(
			0, Info.items.size() + Info.actions.size() - 1)
		newElement = getUniqueElement(arr, newElement)
		arr.append(newElement)
	return arr

# reqursively returns unique element that is not in given array.
func getUniqueElement(arr, elem):
	for j in arr.size():
		if arr[j] == elem:
			return getUniqueElement(arr, (elem + 1)
			 % (Info.items.size() + Info.actions.size() - 1))
	return elem


func destroy():
	queue_free()
