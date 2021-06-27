class_name Penalty
extends Node
var request
var f = {}
var comp = {"ageComp": 0, "distanceComp": 0, "heightComp": 0, "weightComp": 0}
var height_units = "cm"
var weight_units = "kg"
var distance_units = "m"
var likes = []
var dislikes = []
var height
var weight
var distance
var rnd: RandomNumberGenerator = RandomNumberGenerator.new()
var text: String


func _ready():
	text = ""
	rnd.randomize()


func add_penalty(p: Person):
	if p.type > -1:
		match p.type:
			0:
				text = "something's wrong with portrait"
			1:
				text = "name looks odd"
			2:
				text = "do you think a person with that age exists?"
			3:
				text = "is that a real profession?"
			4:
				text = "he can't work in that place"
			5:
				text = "education looks fake"
			6:
				text = "distance is not a positive number"
			7:
				text = "look closely at preferences"
			8:
				text = "dislikes are corrupted"
			9:
				text = "height is not a positive number or units are strange"
			10:
				text = "weight is not a positive number or units are strange"
	elif p.type == Person.pType.FIT:
		text = "profile matches a request"
	else:
		text = "profile doesn't match any request"


func check_coincidence(arr, elem):
	for j in arr.size():
		if arr[j] == elem:
			return check_coincidence(arr, (elem + 1) % 8)
	return elem
