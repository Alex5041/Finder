class_name Request
extends Node
var request
var f = {}
var comp = {"ageComp":0,"distanceComp":0,
"heightComp":0,"weightComp":0}
var height_units = "cm"
var weight_units = "kg"
var distance_units = "m"
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


func add_request(var num):
	request = create_preferences(num)
	#self.get("custom_styles/panel").border_color = Color("7664fe")
#	self.get("custom_styles/panel").corner_radius_top_right = 20
#	self.get("custom_styles/panel").corner_radius_bottom_right = 20
#	self.get("custom_styles/panel").corner_radius_bottom_left = 20
	self.get("custom_styles/panel").bg_color = Color("B7C6D6")
	rnd.randomize()
	for i in request:
		match i:
			# REPLACING REPLACES PREVIOUS REPLACES
			# WTF is the upper commentary?!
			0:
				f["distance"] = rnd.randi_range(11, 999)
				comp["distanceComp"] = rnd.randi_range(0, 2)
			1:
				f["height"] = rnd.randi_range(151, 199)
				comp["heightComp"] = rnd.randi_range(0, 2)
			2:
				f["weight"] = float(rnd.randi_range(4501, 14999))/100
				comp["weightComp"] = rnd.randi_range(0, 2)
			3:
				f["age"] = rnd.randi_range(19, 99)
				comp["ageComp"] = rnd.randi_range(0, 2)
			4:
				if rnd.randi_range(0, 1) == 0:
					f["workType"] = true
					f["workPlace"] = Info.companies[rnd.randi_range(
						0, Info.companies.size()-1)]
				else:
					f["workType"] = false
					f["workProfession"] = Info.jobs[rnd.randi_range(
						0, Info.jobs.size()-1)]
			5:
				if rnd.randi_range(0, 1) == 0:
					f["educationType"] = true
					f["eduType"] = rnd.randi_range(0, 2)
					f["education_place"] = "School" if f.get("eduType") == 0 else (
					"College" if f.get("eduType") == 1 else "University")
				else:
					f["educationType"] = false
					f["educationTown"] = Info.cities[rnd.randi_range(
						0, Info.cities.size()-1)]
			6:
				var like = rnd.randi_range(
					0, Info.items.size() + Info.actions.size() -1)
				likes.append(Info.items[like] if (like < Info.items.size()
				) else Info.actions[like - Info.items.size()])
			7:
# make sure that dislike != like
				var flag = true
				var dislike
				while flag:

					# Eternal cycle - if likes.size() == 0 Fixed.

					dislike = rnd.randi_range(
						0, Info.items.size() + Info.actions.size() -1)
					if likes.size() == 0:
						flag = false
					elif likes[0] != Info.items[dislike] if (
					dislike < Info.items.size()
				) else Info.actions[dislike - Info.items.size()]:
						flag = false
				dislikes.append(Info.items[dislike] if (
					dislike < Info.items.size()
				) else Info.actions[dislike - Info.items.size()])

func writed():
	for i in request:
		rnd.randomize()
		match i:
			0:
				if rnd.randi_range(0, 1) == 0:
					distance_units = "km"
					distance = f.get("distance")/1000.0
				else:
					distance = f.get("distance")
				text += "[img]resources/images/location.png[/img] " + (
					"> " if comp.get("distanceComp") == 1 else (
					"< " if comp.get("distanceComp") == 2 else "= ")) + str(
					distance) + " " + distance_units + "\n"
			1:
				if rnd.randi()%2 == 0:
					height_units = "m"
					height = float(f.get("height")) / 100
				else:
					height = f.get("height")
				text += "[img]resources/images/height.png[/img] " + (
					"> " if comp.get("heightComp") == 1 else (
					"< " if comp.get("heightComp") == 2 else "= ")) + str(
					height) + " " + height_units + "\n"
			2:
				if rnd.randi_range(0, 1) == 0:
					weight_units = "q"
					weight = f.get("weight")
					weight /= 100.0
				else:
					weight = f.get("weight")
				text += "[img]resources/images/weight.png[/img] " + (
					"> " if comp.get("weightComp") == 1 else (
					"< " if comp.get("weightComp") == 2 else "= ")) + str(
					weight) + " " + weight_units + "\n"
			3:
				text += "[img]resources/images/body.png[/img] " + (
					"> " if comp.get("ageComp") == 1 else (
					"< " if comp.get("ageComp") == 2 else "= ")) + str(
					f.get("age")) + " years\n"
			4:
				if f.get("workType"):
					text += "[img]resources/images/suitcase.png[/img] in " + (
						f.get("workPlace") + "\n")
				else:
					text += "[img]resources/images/suitcase.png[/img] as " + (
						f["workProfession"] + "\n")
			5:
				if f.get("educationType"):
					text += "[img]resources/images/book.png[/img] in " + (
						f.get("education_place") + "\n")
				else:
					text += "[img]resources/images/book.png[/img] in " + (
						f.get("educationTown") + "\n")
			6:
				text += "[img]resources/images/heart.png[/img] " + (
						likes[0] + "\n")
			7:
				text += "[img]resources/images/brokenheart.png[/img] " + (
						dislikes[0] + "\n")
	text.erase(text.length()-1,1)



func create_preferences(var num):
	#rnd.randomize()
	var arr = []
	for i in num:
		rnd.randomize()
		var newElement = rnd.randi_range(0, 7)
		newElement = check_coincidence(arr, newElement)
		arr.append(newElement)
	return arr


func check_coincidence(arr, elem):
	for j in arr.size():
		if arr[j] == elem:
			return check_coincidence(arr,(elem + 1) % 8)
	return elem
