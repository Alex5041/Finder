extends Game

var isRoundEnded:bool = false
var endRoundTime = 0
var timeLeft = 20
var upgFlags = [{}, false, false, 0, 0, false, false]
var colorChange = Tween.new()

var timer = Timer.new()

func _ready():
	add_child(colorChange)
	add_child(timer)
	add_child(startTimer)
	startTimer.connect("timeout", self, "oneSecondLessFromStart")
	startTimer.one_shot = true
	roundStart()

func _process(delta):
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


func roundStart():
	countdown = 5
	get_node("VC/TimeLeft/Line2D").points[0].x = -32
	timeLeft = 20 + upgFlags[3]
	isRoundEnded = true
	$VC/TimeLeft.visible = true
	$Overlay/PanelContainer.visible = true
	timer.start(.1)

	timeStart = timeLeft
	
	startTimer.start(1)

func oneSecondLessFromStart():
	countdown -= 1
	if countdown == -1:
		isRoundEnded = false
		$Overlay/PanelContainer.visible = false
		$Overlay/PanelContainer.rect_position = Vector2(500, 119)
	else:
		$Overlay/PanelContainer/CenterContainer/VBoxContainer/Big.text = (
		"You have " + str(countdown) + " s before start")
		startTimer.start(1)


func updateTimeLine(actionRes:bool):
	$VC/TimeLeft/Line2D.default_color = Color("97B2ED" if actionRes else "D55D6F")
	colorChange.interpolate_property(
		$VC/TimeLeft/Line2D,(
			"default_color"),$VC/TimeLeft/Line2D.default_color,Color(
				"F9FAF0"),1,Tween.TRANS_LINEAR)
	colorChange.start()
	timeLeft += 1 if actionRes else -4

func rightAction():
	updateTimeLine(true)
	$Overlay/Top/Score.text = str(Info.rightAction + Info.prevRoundScore
		) + "/" + str((roundNum + 1) * 5)
	$Overlay/Top/Score.add_color_override("font_color", Color("e7acb0") if (
		Info.rightAction + Info.prevRoundScore < (roundNum+ 1 ) * 5
		)  else Color("f3f4e0"))

#
func wrongAction(type):
	.wrongAction(type)
	updateTimeLine(false)
		

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

func _on_Pause_pressed():
	tap()
	Info.save(person, requests)
	Info.gameOver = false
	get_tree().change_scene("res://Title.tscn")
