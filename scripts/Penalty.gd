class_name Penalty
extends Node
var request
var f = {}
var comp = {"ageComp":0,"distanceComp":0,
"heightComp":0,"weightComp":0}
var heightUnits = "cm"
var weightUnits = "kg"
var distanceUnits = "m"
var likes = []
var dislikes = []
var height
var weight
var distance
var rnd:RandomNumberGenerator = RandomNumberGenerator.new()
var text:String

func _ready():
	text = ""
	rnd.randomize()


func addPenalty(p:Person):
#	self.get("custom_styles/panel").border_color = Color("dc534b")
#	self.get("custom_styles/panel").corner_radius_top_right = 0
#	self.get("custom_styles/panel").corner_radius_bottom_right = 0
#	self.get("custom_styles/panel").corner_radius_bottom_left = 0
	if p.broken > -1:
		match p.broken:
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
	elif p.fit:
		text = "profile matches a request"
	else:
		text = "profile doesn't match any request"


func checkCoincidence(arr, elem):
	for j in arr.size():
		if arr[j] == elem:
			return checkCoincidence(arr,(elem + 1) % 8)
	return elem
