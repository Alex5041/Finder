class_name Zen
extends Game


func _ready():
	pass

func right_action():
	correct += 1
	$Right.play()
	Info.right_action += 1
	$Overlay/Top/Score.text = str(Info.right_action) + "/" + str(Info.record)


func wrong_action(var type):
	.wrong_action(type)
	Info.game_over = true
	Info.erase_game()
	$Overlay/PanelGameOver.visible = true


func gameOverOrPenalty(actionTypeText:String):
	Info.game_over = true
	Info.erase_game()
	$Overlay/PanelGameOver.visible = true
	.add_penalty(actionTypeText)
