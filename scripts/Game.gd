class_name Game
extends Node
onready var p = load("Person.tscn")
onready var name_age = get_node(
	"VC/Profile/NameAgeGender/HBC/NameAge")
onready var job = get_node("VC/Profile/Interests/Interests/Job/Job")
onready var education = get_node(
	"VC/Profile/Interests/Interests/Education/Education")
onready var distance = get_node(
	"VC/Profile/Interests/Interests/Distance/Distance")
onready var likes_text = get_node(
	"VC/Profile/Likes/HC/LikesText")
onready var dislikes_text = get_node(
	"VC/Profile/Dislikes/HC/DislikesText")
onready var height = get_node(
	"VC/Profile/HBC/Height/Height/Label")
onready var weight = get_node(
	"VC/Profile/HBC/Weight/Weight/Label")
onready var gender:AnimatedSprite = get_node(
	"VC/Profile/NameAgeGender/HBC/C/AnimatedSprite")
onready var  scroll_container = get_node("VC/Penalty/VSB")
onready var  scroll_container2 = get_node("VC/Request/SC")

var requests = []
var rnd:RandomNumberGenerator = RandomNumberGenerator.new()
var person
var wrong_person_array = []

# index of current wrong person.
var penalty_iter:int = 0
var pol:PoolVector2Array = PoolVector2Array([0])
var chosen = []
var game_state = game_state_enum.REQUEST

var game_over_panel_pressed = false
var countdown = 5
onready var visible_panel = $Like
var total = 0
var correct = 0

enum game_state_enum{
	CURRENT_PROFILE, # In-Profile
	MADE_ERRORS, # In-Wrong-Profiles
	REQUEST,
	OUT # round / game over
}


func _ready():
	rnd.randomize()
	$VC.rect_size = OS.get_window_safe_area().size
	$VC/Profile.rect_pivot_offset = Vector2(
		$VC/Profile.rect_size.x/2,$VC/Profile.rect_size.y*2)
	$VC/Request.rect_pivot_offset = Vector2(
		$VC/Request.rect_size.x/2,$VC/Request.rect_size.y)
	false_visible()
	configure_button_sizes()
	place_face()
	add_request(rnd.randi_range(1, 3))
	create_person()


func info_mode_update():
	display_person(wrong_person_array[penalty_iter].get("person"))
	$VC/Profile/InfoPanel.visible = true
	$VC/Profile/InfoPanel/HBC/ErrorText.text = (
		wrong_person_array[penalty_iter].get("action"))
	$VC/Profile/InfoPanel/HBC/Number.text = str(
	penalty_iter + 1) + "/" + str(wrong_person_array.size()) + "  "


func info_mode_leave():
	game_state = game_state_enum.CURRENT_PROFILE
	$VC/Profile/InfoPanel.visible = false
	$VC/Profile.theme = load("res://resources/theme.tres")
	# that is for showing not wrong profiles in profile tab
	display_person(person)


func right_action():
	correct += 1
	$Right.play()
	Info.right_action += 1
	$Overlay/Top/Score.text = str(Info.right_action)\
		+ "/" + str(Info.record)


func wrong_action(var type) -> void:
	var errorText:String
	match type:
		0:
			errorText = "liked"
		1:
			errorText = "disliked"
		2:
			errorText = "reported"
	$Wrong.play()
	add_penalty(errorText)


func change_visible(new_visible):
	visible_panel.visible = false
	new_visible.visible = true
	visible_panel = new_visible


func false_visible():
	$Like.visible = false
	$Dislike.visible = false
	$Report.visible = false
	$Profile.visible = false
	$Next.visible = false
	$Previous.visible = false
	$Request.visible = false

# 0 like
# 1 dislike
# 2 report
func swipe(var type):
	if game_state == game_state_enum.MADE_ERRORS:
		match type:
			-2:
				penalty_iter -= 1
			-1:
				penalty_iter += 1
		if penalty_iter == wrong_person_array.size():
			penalty_iter = 0
		elif penalty_iter == -1:
			penalty_iter = wrong_person_array.size() - 1
		info_mode_update()
	elif !Info.game_over:
		var typeNow = person.type if person.type < 0 else 0
		if typeNow != type:
			wrong_action(type + 2)
		else:
			right_action()
		create_person()


func display_person(pers:Person):
	pers.writed()
	name_age.text = "  " + pers.f.get("nam") + ", " + str(pers.f.get("age"))
	gender.play("male" if pers.f.get("gender") else "female")
	job.text = pers.job
	education.text = pers.education
	distance.text = str(pers.distance
	) + " " + pers.distance_units

	# likes and dislikes split
	var stringArr = pers.interests_text().rsplit(
		'\n\n')
	if stringArr.size() > 0:
		likes_text.text = stringArr[0]
	if stringArr.size() > 1:
		dislikes_text.text = stringArr[1]

	height.text = str(pers.height) + " " + pers.height_units
	weight.text = str(pers.weight) + " " + pers.weight_units
	$VC/Profile/FaceButtons/Face/Eyes.frame = pers.face[0]
	$VC/Profile/FaceButtons/Face/Nose.frame = pers.face[1]
	$VC/Profile/FaceButtons/Face/Mouth.frame = pers.face[2]
	$VC/Profile/FaceButtons/Face/Hair.frame = pers.face[3]
	$VC/Profile/FaceButtons/Face/Background.frame = pers.face[4]
	if pers.glasses:
		$VC/Profile/FaceButtons/Face/Glasses.frame = pers.face[5]
		$VC/Profile/FaceButtons/Face/Glasses.visible = true
	else:
		$VC/Profile/FaceButtons/Face/Glasses.visible = false


func create_person(data = null):
	total += 1
	person = p.instance()
	add_child(person)
	if data != null:
		print(data)
		person.f = data.get("f")
		person.face = data.get("face")
		person.likes = data.get("likes")
		person.dislikes = data.get("dislikes")
		person.type = data.get("type")
	else:
		var brokenOrFit = rnd.randi_range(-2, 0)
		if brokenOrFit == 0:
			person.make_broken()
		elif brokenOrFit == -1:
			person.make_fit(requests[0])
		else:
			person.type = person.check(requests[0])
	display_person(person)
	print(person.type)


func add_request(var num):
	var r = load("Request.tscn").instance()
	$VC/Request/SC/List.add_child(r)
	r.add_request(num)
	r.writed()
	r.get_node("MarginContainer/RichTextLabel").parse_bbcode(r.text)
	requests.append(r)


func add_penalty(actionTypeText:String):
	$VC/Buttons/Info/infoMode/AnimatedSprite.play()
	var r = load("Penalty.tscn").instance()
	$VC/Penalty/VSB/List.add_child(r)
	r.add_penalty(person)
	print("added fault")
	# adding person to info panel if made a mistake
	wrong_person_array.append({"person":person,"action":actionTypeText+(
		", "+r.text)})
	#r.get_node("MC/RichTextLabel").parse_bbcode(r.text)
#	if(tex != null):
#		r.get_node("MC/RichTextLabel").add_image(tex)
#	get_node("VC/Profile/V/FaceButtons/Buttons/Penalty"
#	).icon.current_frame = 1


func _input(event):
	if event is InputEventScreenTouch\
		and game_state != game_state_enum.OUT:

		if game_state != game_state_enum.REQUEST:
			# Like
			if $VC/Profile.rect_position.x > 35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				swipe(-1)
			# Dislike
			elif $VC/Profile.rect_position.x < -35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				swipe(-2)
			# Report mode
			elif $VC/Profile.rect_position.y < -35 and abs(
				$VC/Profile.rect_position.x) <= 35:
				swipe(0)
			# Request mode
			elif $VC/Profile.rect_position.y > 35 and abs(
				$VC/Profile.rect_position.x) <= 35:
				_on_Request(false)
			$VC/Profile.rect_rotation = 0
			$VC/Profile.rect_position = Vector2()
		else:
			if $VC/Request.rect_position.y > 35 and abs(
				$VC/Request.rect_position.x) <= 35:
				_on_Profile(false)
			$VC/Request.rect_rotation = 0
			$VC/Request.rect_position = Vector2()
		visible_panel.visible = false

	# No action happening
	if event is InputEventScreenDrag and game_state != game_state_enum.OUT:
		if game_state != game_state_enum.REQUEST:
			$VC/Profile.rect_rotation += (event.relative).x / 10
			$VC/Profile.rect_position += event.relative / 3
			# Like
			if $VC/Profile.rect_position.x > 35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				if game_state == game_state_enum.CURRENT_PROFILE:
					change_visible($Like)
				else:
					change_visible($Previous)
			# Dislike
			elif $VC/Profile.rect_position.x < -35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				if game_state == game_state_enum.CURRENT_PROFILE:
					change_visible($Dislike)
				else:
					change_visible($Next)
			# Report
			elif $VC/Profile.rect_position.y < -35 and abs(
				$VC/Profile.rect_position.x) <= 35 and (
				game_state == game_state_enum.CURRENT_PROFILE):
				change_visible($Report)
			# Profile
			elif $VC/Profile.rect_position.y > 35 and abs(
				$VC/Profile.rect_position.x) <= 35 and (
				game_state == game_state_enum.CURRENT_PROFILE):
				change_visible($Request)
			else:
				visible_panel.visible = false
		else:
			$VC/Request.rect_rotation += (event.relative).x / 10
			$VC/Request.rect_position += event.relative / 3
			if $VC/Request.rect_position.y > 35 and abs(
				$VC/Request.rect_position.x) <= 35:
				change_visible($Profile)
			else:
				visible_panel.visible = false
		#elif $VC/Penalty.visible == true:
		#	scroll_container.scroll_vertical -= event.relative.y

	# Delete in release.
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_RIGHT:
			person.queue_free()
			create_person()


func _on_Pause():
	tap()
	Info.save(person, requests)
	Info.game_over = false
	get_tree().change_scene("res://Title.tscn")


func _on_Profile(flag):
	visible_panel.visible = false
	game_state = game_state_enum.CURRENT_PROFILE
	info_mode_leave()
	if flag:
		tap()
	$VC/Buttons/Request/requestMode.flat = true
	$VC/Buttons/Profile/profileMode.flat = false
	$VC/Buttons/Info/infoMode.flat = true
	get_node("VC/Request").visible = false
	get_node("VC/Profile").visible = true
	get_node("VC/Profile/InfoPanel").visible = false
	get_node("VC/Profile/FaceButtons/Face").visible = true
	get_node("VC/Profile/FaceButtons/CC").visible = false


func _on_Request(flag):
	visible_panel.visible = false
	game_state = game_state_enum.REQUEST
	if flag:
		tap()
#	if countdown < 0:
#		$Overlay/PanelContainer.visible = false
	$VC/Buttons/Request/requestMode.flat = false
	$VC/Buttons/Profile/profileMode.flat = true
	$VC/Buttons/Info/infoMode.flat = true
	get_node("VC/Profile").visible = false
	get_node("VC/Request").visible = true

# Info button
func _on_Errors_Made(flag):
	if wrong_person_array.size() > 0:
		if flag:
			tap()
		info_mode_update()
		game_state = game_state_enum.MADE_ERRORS
#		$Overlay/PanelContainer.visible = false
		$VC/Profile.theme = load("res://resources/reportTheme.tres")
		tap()
		$VC/Buttons/Request/requestMode.flat = true
		$VC/Buttons/Profile/profileMode.flat = true
		$VC/Buttons/Info/infoMode.flat = false
		get_node("VC/Profile/InfoPanel").visible = true
		get_node("VC/Request").visible = false
		get_node("VC/Profile").visible = true
		get_node("VC/Buttons/Info/infoMode/AnimatedSprite").stop()
		get_node("VC/Buttons/Info/infoMode/AnimatedSprite").frame = 0



func to_title():
	print("Title")


func tap():
	$Tap.set_pitch_scale(randf()/4+0.9)
	$Tap.play()



# panel buttons changing sizes.
func configure_button_sizes():
	$VC/Buttons/Info/infoMode/AnimatedSprite.position = Vector2(
		$VC/Buttons/Info.rect_position.x+$VC/Buttons/Info.rect_size.x/2,
		$VC/Buttons/Info.rect_position.y+$VC/Buttons/Info.rect_size.y/2)
	$VC/Buttons/Request/requestMode/Sprite.position = Vector2(
		$VC/Buttons/Info.rect_position.x+$VC/Buttons/Info.rect_size.x/2,
		$VC/Buttons/Info.rect_position.y+$VC/Buttons/Info.rect_size.y/2)
	$VC/Buttons/Profile/profileMode/Sprite.position = Vector2(
		$VC/Buttons/Info.rect_position.x+$VC/Buttons/Info.rect_size.x/2,
		$VC/Buttons/Info.rect_position.y+$VC/Buttons/Info.rect_size.y/2)

# placing face features.
func place_face():
	$VC/Profile/FaceButtons/Face/Background.position = Vector2(
		$VC/Profile.rect_size.x/2-
		$VC/Profile/FaceButtons/Face/Background.frames.get_frame(
			"default", 0).get_width()/2+85, 125)

	$VC/Profile/FaceButtons/Face/Eyes.position = Vector2(
		$VC/Profile.rect_size.x/2-
		$VC/Profile/FaceButtons/Face/Eyes.frames.get_frame(
			"default", 1).get_width()/2, 105)

	$VC/Profile/FaceButtons/Face/Nose.position = Vector2(
		$VC/Profile.rect_size.x/2-
		$VC/Profile/FaceButtons/Face/Nose.frames.get_frame(
			"default", 1).get_width()/2+3, 139)

	$VC/Profile/FaceButtons/Face/Mouth.position = Vector2(
		$VC/Profile.rect_size.x/2-
		$VC/Profile/FaceButtons/Face/Mouth.frames.get_frame(
			"default", 1).get_width()/2+5, 165)

	$VC/Profile/FaceButtons/Face/Hair.position = Vector2(
		$VC/Profile.rect_size.x/2-
		$VC/Profile/FaceButtons/Face/Hair.frames.get_frame(
			"default", 1).get_width()/2+42, 110)

	$VC/Profile/FaceButtons/Face/Glasses.position = Vector2(
		$VC/Profile.rect_size.x/2-
		$VC/Profile/FaceButtons/Face/Glasses.frames.get_frame(
			"default", 0).get_width()/2+4, 120)


func on_PanelGameOver_pressed(event):
	if event is InputEventScreenTouch:
		print("touch")
		if game_over_panel_pressed:
			panel_push(true, get_node("Overlay/PanelGameOver"))
			get_tree().change_scene("Submit.tscn")
		else:
			panel_push(false, get_node("Overlay/PanelGameOver"))
			
		game_over_panel_pressed = !game_over_panel_pressed
	pass # Replace with function body.

func panel_push(press, node):
	tap()
	if press:
		node.get("custom_styles/panel").border_color = Color("958fa3")
		node.rect_position += Vector2(0, -10)
	else:
		#$Overlay/PanelContainer.margin_top = -10
		node.get("custom_styles/panel").border_color = 0
		node.rect_position += Vector2(0, 10)
