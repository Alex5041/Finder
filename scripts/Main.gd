class_name GameClass
extends Node
onready var p = load("Person.tscn")
onready var nameAge = get_node(
	"VC/Profile/NameAgeGender/HBC/NameAge")
onready var job = get_node("VC/Profile/Interests/Interests/Job/Job")
onready var education = get_node(
	"VC/Profile/Interests/Interests/Education/Education")
onready var distance = get_node(
	"VC/Profile/Interests/Interests/Distance/Distance")
onready var likesText = get_node(
	"VC/Profile/Likes/HC/LikesText")
onready var dislikesText = get_node(
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
var wrongPersonArray = []
var penaltyIter:int = 0
var tex
var canShoot:bool = false
var timer = Timer.new()
onready var startTimer = Timer.new()
var pol:PoolVector2Array = PoolVector2Array([0])
var timeLeft = 20
var upgFlags = [{}, false, false, 0, 0, false, false]
var chosen = []
var isRoundEnded:bool = false
var endRoundTime = 0
var actionType = actionTypeEnum.SWIPING
var timeStart = 5
var gameOverPressed = false
var colorChange = Tween.new()
var countdown = 5
var roundNum = 0

var total = 0
var correct = 0

enum actionTypeEnum{
	SWIPING,
	PENALTY_INFO
	TIME_OUT
}

func _process(delta):
	if Info.arcade:
		if timeLeft < 0 and !isRoundEnded:
			$TimeIsUp.play()
			# Round ended.
			# all one-round upgrades are destroyed
			upgFlags[1] = false; upgFlags[2] = false; upgFlags[6] = false;
			upgFlags[5] = false
			$Overlay/PanelContainer/CenterContainer/VBoxContainer/Big.text = (
			"Time out!")
			$Overlay/PanelContainer/CenterContainer/VBoxContainer/Small.text = (
			"press this to proceed to powerups")
			$Overlay/PanelContainer.visible = true
			colorChange.interpolate_property($Overlay/PanelContainer,(
					"rect_position"),$Overlay/PanelContainer.rect_position,(
						Vector2(73, 119)),0.45,Tween.TRANS_ELASTIC)
			colorChange.start()
			endRoundTime = timeLeft
			isRoundEnded = true
			print()
			print(total)
			print(correct)
		elif countdown < 0:
			timeLeft -= delta
			get_node("VC/TimeLeft/Line2D").points[0].x = (
			timeStart-timeLeft)/timeStart*480-32

func _ready():
	#if Info.arcade:
	#	Info.rightAction = 5
	add_child(colorChange)
	add_child(timer)
	add_child(startTimer)
	startTimer.connect("timeout", self, "oneSecondLessFromStart")
	startTimer.one_shot = true
	rnd.randomize()
	$VC.rect_size = OS.get_window_safe_area().size
	#$VC/Profile.rect_global_position = Vector2()
	$VC/Profile.rect_pivot_offset = Vector2(
		$VC/Profile.rect_size.x/2,$VC/Profile.rect_size.y*2)
	$VC/Request.rect_pivot_offset = Vector2(
		$VC/Request.rect_size.x/2,$VC/Request.rect_size.y)
	$Like.visible = false
	$Dislike.visible = false
	$Report.visible = false
	$Profile.visible = false
	$Next.visible = false
	$Previous.visible = false
	$Request.visible = false
	configureButtonSizes()
	placeFace()

	roundStart()

func roundStart():
	roundNum += 1
	countdown = 5
	get_node("VC/TimeLeft/Line2D").points[0].x = -32
	$Overlay/PanelContainer.rect_position = Vector2(28, 500)
	$Overlay/PanelContainer/CenterContainer/VBoxContainer/Big.text = (
		"You have " + str(countdown) + " s before start")
	timeLeft = 20 + upgFlags[3]
	
	$VC/Upgrades.visible = false
	$VC/Buttons.visible = true
	if Info.arcade:
		isRoundEnded = true
		$VC/TimeLeft.visible = true
		$Overlay/PanelContainer.visible = true
	timer.start(.1)
	if requests.size() > 0:
		requests[0].queue_free()
		requests.clear()
	addRequest(rnd.randi_range(1, 3))
	createPerson(Info.loadGame() if Info.loaded else null)
	#Info.rightAction = 0
	if !Info.arcade:
		$Overlay/Top/Score.text = str(Info.rightAction) + "/" + str(Info.record)
	else:
		$Overlay/Top/Score.text = str(Info.rightAction + Info.prevRoundScore
		) + "/" + str((roundNum + 1) * 5)
		$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
			Info.rightAction < (roundNum+1)*5)  else Color("f3f4e0"))
	timeStart = timeLeft
	
	startTimer.start(1)
	_on_Request_pressed(false)


func oneSecondLessFromStart():
	if Info.arcade:
		countdown -= 1
		if countdown == -1:
			isRoundEnded = false
			$Overlay/PanelContainer.visible = false
			$Overlay/PanelContainer.rect_position = Vector2(500, 119)
		else:
			$Overlay/PanelContainer/CenterContainer/VBoxContainer/Big.text = (
			"You have " + str(countdown) + " s before start")
			startTimer.start(1)


func createChosen():
	chosen.clear()
	var upgs = []
	for i in Info.upgrades:
		upgs.append(i)
	for i in 3:
		var ind = rnd.randi_range(0, upgs.size() - 1)
		chosen.append(upgs[ind])
		upgs.remove(ind)

	$VC/Upgrades/GC/VB/Upg0.icon = load(chosen[0].get("image"))
	$VC/Upgrades/GC/VB/Text.text = chosen[0].get("text")
	$VC/Upgrades/GC/VB2/Upg1.icon = load(chosen[1].get("image"))
	$VC/Upgrades/GC/VB2/Text.text = chosen[1].get("text")
	$VC/Upgrades/GC/VB3/Upg2.icon = load(chosen[2].get("image"))
	$VC/Upgrades/GC/VB3/Text.text = chosen[2].get("text")


func infoModeUpdate():
	displayPerson(wrongPersonArray[penaltyIter].get("person"))
	$VC/Profile/InfoPanel/HBC/ErrorText.text = (
		wrongPersonArray[penaltyIter].get("action"))
	$VC/Profile/InfoPanel/HBC/Number.text = str(
	penaltyIter + 1)+"/"+str(wrongPersonArray.size()) + "  "

func infoModeLeave():
	actionType = actionTypeEnum.SWIPING
	$VC/Profile.theme = load("res://resources/theme.tres")

func _input(event):
	if event is InputEventScreenTouch:
		if $VC/Profile.visible:
			# Like
			if $VC/Profile.rect_position.x > 35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				swiping(0)
			# Dislike
			elif $VC/Profile.rect_position.x < -35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				swiping(1)
			# Report mode
			elif $VC/Profile.rect_position.y < -35 and abs(
				$VC/Profile.rect_position.x) <= 35:
				swiping(2)
			# Request mode
			elif $VC/Profile.rect_position.y > 35 and abs(
				$VC/Profile.rect_position.x) <= 35:
				_on_Request_pressed(false)
			$VC/Profile.rect_rotation = 0
			$Like.visible = false
			$Dislike.visible = false
			$Report.visible = false
			$Request.visible = false
			$Next.visible = false
			$Previous.visible = false
			$VC/Profile.rect_position = Vector2()
		elif $VC/Request.visible:
			if $VC/Request.rect_position.y > 35 and abs(
				$VC/Request.rect_position.x) <= 35:
					_on_Return_pressed(false)
			$VC/Request.rect_rotation = 0
			$Profile.visible = false
			$VC/Request.rect_position = Vector2()

	if event is InputEventScreenDrag:
		if $VC/Profile.visible == true:
			$VC/Profile.rect_rotation += (event.relative).x/10
			$VC/Profile.rect_position += event.relative/3
			# Like
			if $VC/Profile.rect_position.x > 35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				if actionType == actionTypeEnum.SWIPING:
					$Like.visible = true
				else:
					$Previous.visible = true
			# Dislike
			elif $VC/Profile.rect_position.x < -35 and abs(
				$VC/Profile.rect_position.y) <= 35:
				if actionType == actionTypeEnum.SWIPING:
					$Dislike.visible = true
				else:
					$Next.visible = true
			# Report
			elif $VC/Profile.rect_position.y < -35 and abs(
				$VC/Profile.rect_position.x) <= 35 and (
					actionType == actionTypeEnum.SWIPING):
				$Report.visible = true
			# Profile
			elif $VC/Profile.rect_position.y > 35 and abs(
				$VC/Profile.rect_position.x) <= 35 and (
					actionType == actionTypeEnum.SWIPING):
				$Request.visible = true
			else:
				$Report.visible = false
				$Dislike.visible = false
				$Like.visible = false
				$Request.visible = false
				$Next.visible = false
				$Previous.visible = false
			#$VC/Profile.rect_scale = Vector2(0.9, 0.9)
			#$Like.modulate.a = $VC/Profile.rect_rotation/360
		elif $VC/Request.visible == true:
			$VC/Request.rect_rotation += (event.relative).x/10
			$VC/Request.rect_position += event.relative/3
			if $VC/Request.rect_position.y > 35 and abs(
				$VC/Request.rect_position.x) <= 35:
					$Profile.visible = true
			else:
				$Profile.visible = false
		elif $VC/Penalty.visible == true:
			scroll_container.scroll_vertical -= event.relative.y
#		elif $VC/Request.visible == true:
#			scroll_container2.scroll_vertical -= event.relative.y

	# Delete in release.
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_RIGHT:
#			for i in get_tree().get_root().get_children():
#				print(i.get_class())
#				for j in i.get_children():
#					print("    " + j.get_class())
			person.queue_free()
			createPerson()

func rightAction():
	$VC/TimeLeft/Line2D.default_color = Color("97B2ED")
	colorChange.interpolate_property(
		$VC/TimeLeft/Line2D,(
			"default_color"),$VC/TimeLeft/Line2D.default_color,Color(
				"F9FAF0"),1,Tween.TRANS_LINEAR)
	colorChange.start()
	correct += 1
	timeLeft += 1
	$Right.play()
	Info.rightAction += 1
	if !Info.arcade:
		$Overlay/Top/Score.text = str(Info.rightAction) + "/" + str(Info.record)
	else:
		$Overlay/Top/Score.text = str(Info.rightAction + Info.prevRoundScore
		) + "/" + str((roundNum + 1) * 5)
		$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
			Info.rightAction + Info.prevRoundScore < (roundNum+1)*5
			)  else Color("f3f4e0"))
	person.queue_free()

# 0 like
# 1 dislike
# 2 report
func swiping(var type):
	if actionType == actionTypeEnum.PENALTY_INFO:
		match type:
			0:
				penaltyIter -= 1
			1:
				penaltyIter +=1
		if penaltyIter == wrongPersonArray.size():
			penaltyIter = 0
		elif penaltyIter == -1:
			penaltyIter = wrongPersonArray.size() - 1
		infoModeUpdate()
		return
	elif !Info.gameOver and !isRoundEnded:
		if type == 2 and person.broken > -1:
			rightAction()
		elif person.fit and type == 0 and person.broken == -1:
			rightAction()
		elif !person.fit and type == 1 and person.broken == -1:
			rightAction()
		# Wrong action
		else:
			var errorText:String
			match type:
				0:
					errorText = "liked"
				1:
					errorText = "disliked"
				2:
					errorText = "reported"
			timeLeft -= 4
			$Wrong.play()
			$VC/TimeLeft/Line2D.default_color = Color("D55D6F")
			colorChange.interpolate_property(
				$VC/TimeLeft/Line2D,(
					"default_color"),$VC/TimeLeft/Line2D.default_color,Color(
						"F9FAF0"),1,Tween.TRANS_LINEAR)
			colorChange.start()
			gameOverOrPenalty(errorText)
		createPerson()


#func timeout():
#	var image = get_viewport().get_texture().get_data()
#	image.flip_y()
#	image.resize((get_viewport().size.x-50)/2,(
#		get_viewport().size.x-50)/2*854/480)
#	tex = ImageTexture.new()
#	tex.create_from_image(image)
#	timer.stop()


func displayPerson(pers:Person):
	pers.writed()
	nameAge.text = "  " + pers.f.get("nam") + ", " + str(pers.f.get("age"))
	gender.play("male" if pers.f.get("gender") else "female")
	job.text = pers.job
	education.text = pers.education
	distance.text = str(pers.distance
	) + " " + pers.distanceUnits

	# likes and dislikes split
	var stringArr = pers.interestsText().rsplit(
		'\n\n')
	if stringArr.size() > 0:
		likesText.text = stringArr[0]
	if stringArr.size() > 1:
		dislikesText.text = stringArr[1]

	height.text = str(pers.height) + " " + pers.heightUnits
	weight.text = str(pers.weight) + " " + pers.weightUnits
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

func createPerson(data = null):
	total += 1
	person = p.instance()
	add_child(person)
	print(data)
	if data != null:
		person.f = data.get("f")
		person.face = data.get("face")
		person.likes = data.get("likes")
		person.dislikes = data.get("dislikes")
		person.fit = data.get("fit")
	else:
		var brokenOrFit = rnd.randi_range(0, 4)
		if brokenOrFit == 4:
			person.makeBroken()
		elif brokenOrFit <= 1:
			person.makeFit(requests[0])
	displayPerson(person)
	if !person.fit :
		person.fit = person.check(requests[0])
	print(person.fit)
	print(person.broken)


func addRequest(var num):
	var r = load("Message.tscn").instance()
	$VC/Request/SC/List.add_child(r)
	r.addRequest(num)
	r.writed()
	r.get_node("MarginContainer/RichTextLabel").parse_bbcode(r.text)
	requests.append(r)


func addPenalty(actionTypeText:String):
	$VC/Buttons/Info/infoMode/AnimatedSprite.play()
	var r = load("Penalty.tscn").instance()
	$VC/Penalty/VSB/List.add_child(r)
	r.addPenalty(person)
	wrongPersonArray.append({"person":person,"action":actionTypeText+(
		", "+r.text)})
	#r.get_node("MC/RichTextLabel").parse_bbcode(r.text)
#	if(tex != null):
#		r.get_node("MC/RichTextLabel").add_image(tex)
#	get_node("VC/Profile/V/FaceButtons/Buttons/Penalty"
#	).icon.current_frame = 1


func _on_Pause_pressed():
	tap()
	Info.save(person, requests)
	Info.gameOver = false
	get_tree().change_scene("res://Title.tscn")


func _on_Return_pressed(flag):
	infoModeLeave()
	if flag:
		tap()
	if isRoundEnded:
		$Overlay/PanelContainer.visible = true
	$VC/Buttons/Report/reportMode.flat = true
	$VC/Buttons/Request/requestMode.flat = true
	$VC/Buttons/Profile/profileMode.flat = false
	$VC/Buttons/Info/infoMode.flat = true
	get_node("VC/Request").visible = false
	get_node("VC/Profile").visible = true
	get_node("VC/Profile/InfoPanel").visible = false
	get_node("VC/Profile/FaceButtons/Face").visible = true
	get_node("VC/Profile/FaceButtons/CC").visible = false


func _on_Request_pressed(flag):
	if flag:
		tap()
	if isRoundEnded and countdown < 0:
		$Overlay/PanelContainer.visible = false
	elif isRoundEnded:
		$Overlay/PanelContainer.visible = true
	$VC/Buttons/Report/reportMode.flat = true
	$VC/Buttons/Request/requestMode.flat = false
	$VC/Buttons/Profile/profileMode.flat = true
	$VC/Buttons/Info/infoMode.flat = true
	get_node("VC/Profile").visible = false
	get_node("VC/Request").visible = true

# Info button
func _on_Penalty_pressed():
	if wrongPersonArray.size() > 0:
		infoModeUpdate()
		actionType = actionTypeEnum.PENALTY_INFO
		$Overlay/PanelContainer.visible = false
		$VC/Profile.theme = load("res://resources/reportTheme.tres")
		tap()
		$VC/Buttons/Report/reportMode.flat = true
		$VC/Buttons/Request/requestMode.flat = true
		$VC/Buttons/Profile/profileMode.flat = true
		$VC/Buttons/Info/infoMode.flat = false
		get_node("VC/Profile/InfoPanel").visible = true
		get_node("VC/Request").visible = false
		get_node("VC/Profile").visible = true
		get_node("VC/Buttons/Info/infoMode/AnimatedSprite").stop()
		get_node("VC/Buttons/Info/infoMode/AnimatedSprite"
		).frame = 0


func _on_Report_pressed():
	tap()
	$VC/Buttons/Report/reportMode.flat = false
	$VC/Buttons/Profile/profileMode.flat = true
	$VC/Buttons/Request/requestMode.flat = true
	$VC/Buttons/Info/infoMode.flat = true
	get_node("VC/Request").visible = false
	get_node("VC/Penalty").visible = false
	get_node("VC/Profile").visible = true
	get_node("VC/Profile/FaceButtons/Face").visible = false
	get_node("VC/Profile/FaceButtons/CC").visible = true


func reportButtonGeneral(indStart:int, indEnd:int):
	tap()
	timer.start(.1)
	if person.broken >= indStart and person.broken <= indEnd:
		$Right.play()
		timeLeft += 1
		Info.rightAction += 1
	else:
		timeLeft -= 4
		$Wrong.play()
		gameOverOrPenalty("LOL")
	createPerson()
	get_node("VC/Profile/FaceButtons/CC").visible = false
	get_node("VC/Profile/FaceButtons/Face").visible = true


func gameOverOrPenalty(actionTypeText:String):
	if !Info.arcade:
		isRoundEnded = true
#		Info.image = tex
		Info.gameOver = true
		Info.eraseGame()
		$Overlay/PanelContainer.visible = true
		$Overlay/PanelContainer/CenterContainer/VBoxContainer/Big.text = (
			"Game Over!")
		$Overlay/PanelContainer/CenterContainer/VBoxContainer/Small.text = (
			"press this to proceed")
#		get_tree().change_scene("res://Title.tscn")
#	else:
	addPenalty(actionTypeText)


func toTitle():
	print("Title")


func processUpgrades(ind:int):
	var upg = chosen[ind]
	print(Info.rightAction)
	match upg.get("num"):
		0:
			print("hard")
		3:
			if Info.upgCost[3] <= Info.rightAction:
				upgFlags[3] += 5
				Info.rightAction -= Info.upgCost[3]
				print("Bought")
				roundStart()
			else:
				$VC/Upgrades/Label.text = "Not enough points!"
		4:
			if Info.upgCost[4] <= Info.rightAction:
				upgFlags[4] += 1
				Info.rightAction -= Info.upgCost[4]
				print("Bought")
				roundStart()
			else:
				$VC/Upgrades/Label.text = "Not enough points!"
		_:
			if Info.upgCost[upg.get("num")] <= Info.rightAction:
				upgFlags[upg.get("num")] = true
				Info.rightAction -= Info.upgCost[upg.get("num")]
				print("Bought")
				roundStart()
			else:
				$VC/Upgrades/Label.text = "Not enough points!"

func _on_Face_pressed():
	reportButtonGeneral(0, 0)


func _on_Suitcase_pressed():
	reportButtonGeneral(3, 4)


func _on_Book_pressed():
	reportButtonGeneral(5, 5)


func _on_Location_pressed():
	reportButtonGeneral(6, 6)


func _on_Tag_pressed():
	reportButtonGeneral(1, 2)


func _on_Heart_pressed():
	reportButtonGeneral(7, 8)


func _on_Height_pressed():
	reportButtonGeneral(9, 9)


func _on_Weight_pressed():
	reportButtonGeneral(10, 10)

func tap():
	$Tap.set_pitch_scale(randf()/4+0.9)
	$Tap.play()


func _on_Upg0_pressed():
	processUpgrades(0)


func _on_Upg1_pressed():
	processUpgrades(1)


func _on_Upg2_pressed():
	processUpgrades(2)


func _on_UpgNothing_pressed():
	roundStart()

# panel buttons changing sizes.
func configureButtonSizes():
	$VC/Buttons/Info/infoMode/AnimatedSprite.position = Vector2(
		$VC/Buttons/Info.rect_position.x+$VC/Buttons/Info.rect_size.x/2,
		$VC/Buttons/Info.rect_position.y+$VC/Buttons/Info.rect_size.y/2)
	$VC/Buttons/Report/reportMode/Sprite.position = Vector2(
		$VC/Buttons/Info.rect_position.x+$VC/Buttons/Info.rect_size.x/2,
		$VC/Buttons/Info.rect_position.y+$VC/Buttons/Info.rect_size.y/2)
	$VC/Buttons/Request/requestMode/Sprite.position = Vector2(
		$VC/Buttons/Info.rect_position.x+$VC/Buttons/Info.rect_size.x/2,
		$VC/Buttons/Info.rect_position.y+$VC/Buttons/Info.rect_size.y/2)
	$VC/Buttons/Profile/profileMode/Sprite.position = Vector2(
		$VC/Buttons/Info.rect_position.x+$VC/Buttons/Info.rect_size.x/2,
		$VC/Buttons/Info.rect_position.y+$VC/Buttons/Info.rect_size.y/2)

# placing face features.
func placeFace():
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


func _on_TimeOutOrGameOver(event):
	if event is InputEventScreenTouch:
		if gameOverPressed:
			gameOverPressed = false
			$Overlay/PanelContainer.get("custom_styles/panel").border_color = Color("958fa3")
			$Overlay/PanelContainer.rect_position += Vector2(0, -10)
			if Info.arcade:
				Info.rightAction -= (roundNum + 1) * 5
				$Overlay/Top/Score.text = str(Info.rightAction + Info.prevRoundScore
					) + "/" + str((roundNum + 1) * 5)
				$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
					Info.rightAction + Info.prevRoundScore < (roundNum+1)*5
					)  else Color("f3f4e0"))
				createChosen()
				$VC/Profile.visible = false
				$VC/Buttons.visible = false
				$VC/TimeLeft.visible = false
				$Overlay/PanelContainer.visible = false
				$VC/Upgrades.visible = true
			else:
				toTitle()
		elif countdown == -1 or !Info.arcade:
			tap()
			gameOverPressed = true
			#$Overlay/PanelContainer.margin_top = -10
			$Overlay/PanelContainer.get("custom_styles/panel").border_color = 0
			$Overlay/PanelContainer.rect_position += Vector2(0, 10)
		elif countdown > -1:
			tap()
			countdown = 0
			startTimer.stop()
			oneSecondLessFromStart()
