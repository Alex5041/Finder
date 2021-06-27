extends Game

var isRoundEnded:bool = false
var endRoundTime = 0
var timeLeft = 20
var upgFlags = [{}, false, false, 0, 0, false, false]
var colorChange = Tween.new()
var roundNum = 0
var timeStart = 5
var startTimer = Timer.new()
var start_panel_pressed = false
var upg_panel_pressed = false

var timer = Timer.new()

func _ready():
	add_child(colorChange)
	add_child(timer)
	add_child(startTimer)
	startTimer.connect("timeout", self, "one_second_less_from_start")
	startTimer.one_shot = true
	roundStart()

func _process(delta):
	if timeLeft < 0 and !isRoundEnded:
		$TimeIsUp.play()
		# Round ended.
		# all one-round upgrades are destroyed
		upgFlags[1] = false; upgFlags[2] = false; upgFlags[6] = false;
		upgFlags[5] = false
		$Overlay/PanelToUpgrades.visible = true
		colorChange.interpolate_property($Overlay/PanelToUpgrades,(
				"rect_position"),$Overlay/PanelToUpgrades.rect_position,(
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

# creates upgrades
func create_chosen():
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


func roundStart():
	countdown = 5
	get_node("VC/TimeLeft/Line2D").points[0].x = -32
	timeLeft = 20 + upgFlags[3]
	isRoundEnded = true
	$VC/TimeLeft.visible = true
	$Overlay/PanelStart.visible = true
	timer.start(.1)
	timeStart = timeLeft
	startTimer.start(1)

func one_second_less_from_start():
	countdown -= 1
	if countdown == -1:
		isRoundEnded = false
		$Overlay/PanelStart.visible = false
		$Overlay/PanelStart.rect_position = Vector2(500, 119)
	else:
		$Overlay/PanelStart/CenterContainer/VBoxContainer/Big.text = (
		"You have " + str(countdown) + " s before start")
		startTimer.start(1)

# func roundStart():
# 	roundNum += 1
# 	$Overlay/PanelContainer.rect_position = Vector2(28, 500)
# 	$Overlay/PanelContainer/CenterContainer/VBoxContainer/Big.text = (
# 		"You have " + str(countdown) + " s before start")

# 	$VC/Upgrades.visible = false
# 	$VC/Buttons.visible = true
# 	$VC/Profile.visible = false

# 	if requests.size() > 0:
# 		requests[0].queue_free()
# 		requests.clear()
# 	add_request(rnd.randi_range(1, 3))
# 	createPerson(Info.load_game() if Info.loaded else null)

# 	if !Info.arcade:
# 		$Overlay/Top/Score.text = str(Info.right_action) + "/" + str(Info.record)
# 	else:
# 		$Overlay/Top/Score.text = str(Info.right_action + Info.prev_round_score
# 		) + "/" + str((roundNum + 1) * 5)
# 		$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
# 			Info.right_action < (roundNum+1)*5)  else Color("f3f4e0"))

# func _on_TimeOutOrGameOver(event):
# 	if event is InputEventScreenTouch:
# 		if gameOverPressed:
# 			gameOverPressed = false
# 			$Overlay/PanelContainer.get("custom_styles/panel").border_color = Color("958fa3")
# 			$Overlay/PanelContainer.rect_position += Vector2(0, -10)
# 			if Info.arcade:
# 				Info.right_action -= (roundNum + 1) * 5
# 				$Overlay/Top/Score.text = str(Info.right_action + Info.prev_round_score
# 					) + "/" + str((roundNum + 1) * 5)
# 				$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
# 					Info.right_action + Info.prev_round_score < (roundNum+1)*5
# 					)  else Color("f3f4e0"))
# 				createChosen()
# 				$VC/Profile.visible = false
# 				$VC/Buttons.visible = false
# 				$VC/TimeLeft.visible = false
# 				$Overlay/PanelContainer.visible = false
# 				$VC/Upgrades.visible = true
# 			else:
# 				toTitle()
# 		elif countdown == -1 or !Info.arcade:
# 			tap()
# 			gameOverPressed = true
# 			#$Overlay/PanelContainer.margin_top = -10
# 			$Overlay/PanelContainer.get("custom_styles/panel").border_color = 0
# 			$Overlay/PanelContainer.rect_position += Vector2(0, 10)
# 		elif countdown > -1:
# 			tap()
# 			countdown = 0
# 			startTimer.stop()



func updateTimeLine(actionRes:bool):
	$VC/TimeLeft/Line2D.default_color = Color("97B2ED" if actionRes else "D55D6F")
	colorChange.interpolate_property(
		$VC/TimeLeft/Line2D,(
			"default_color"),$VC/TimeLeft/Line2D.default_color,Color(
				"F9FAF0"),1,Tween.TRANS_LINEAR)
	colorChange.start()
	timeLeft += 1 if actionRes else -4

func right_action():
	.right_action()
	updateTimeLine(true)
	$Overlay/Top/Score.text = str(Info.right_action + Info.prev_round_score
		) + "/" + str((roundNum + 1) * 5)
	$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
		Info.right_action + Info.prev_round_score < (roundNum+ 1 ) * 5
		)  else Color("f3f4e0"))

#
func wrong_action(type):
	.wrong_action(type)
	updateTimeLine(false)
		

func processUpgrades(ind:int):
	var upg = chosen[ind]
	print(Info.right_action)
	match upg.get("num"):
		0:
			print("hard")
		3:
			if Info.upgCost[3] <= Info.right_action:
				upgFlags[3] += 5
				Info.right_action -= Info.upgCost[3]
				print("Bought")
				roundStart()
			else:
				$VC/Upgrades/Label.text = "Not enough points!"
		4:
			if Info.upgCost[4] <= Info.right_action:
				upgFlags[4] += 1
				Info.right_action -= Info.upgCost[4]
				print("Bought")
				roundStart()
			else:
				$VC/Upgrades/Label.text = "Not enough points!"
		_:
			if Info.upgCost[upg.get("num")] <= Info.right_action:
				upgFlags[upg.get("num")] = true
				Info.right_action -= Info.upgCost[upg.get("num")]
				print("Bought")
				roundStart()
			else:
				$VC/Upgrades/Label.text = "Not enough points!"

func _on_Upg0_pressed():
	processUpgrades(0)


func _on_Upg1_pressed():
	processUpgrades(1)


func _on_Upg2_pressed():
	processUpgrades(2)


func _on_UpgNothing_pressed():
	roundStart()



func onTimeOut():
	pass

func _on_PanelStart_pressed(event):
	if event is InputEventScreenTouch:
		if start_panel_pressed:
			panel_push(true, get_node("Overlay/PanelStart"))
			countdown = 0
			one_second_less_from_start()
			$VC/Profile.visible = true
			$VC/Request.visible = false
		else:
			panel_push(false, get_node("Overlay/PanelStart"))
#			elif countdown == -1 or !Info.arcade:
#				tap()
#				panel_push(false, get_node("Overlay/PanelStart"))
#
#			elif countdown > -1:
#				tap()
#				countdown = 0
#				startTimer.stop()
		start_panel_pressed = !start_panel_pressed


func _on_PanelToUpgrades_pressed(event):
	if event is InputEventScreenTouch:
		if upg_panel_pressed:
			create_chosen()
			panel_push(true, get_node("Overlay/PanelToUpgrades"))
			$VC/Profile.visible = false
			$VC/Buttons.visible = false
			$VC/TimeLeft.visible = false
			$Overlay/PanelToUpgrades.visible = false
			$VC/Upgrades.visible = true
			Info.right_action -= (roundNum + 1) * 5
			$Overlay/Top/Score.text = str(Info.right_action + Info.prev_round_score
				) + "/" + str((roundNum + 1) * 5)
			$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
				Info.right_action + Info.prev_round_score < (roundNum+1)*5
				)  else Color("f3f4e0"))
		else:
			panel_push(false, get_node("Overlay/PanelToUpgrades"))
		upg_panel_pressed = !upg_panel_pressed
