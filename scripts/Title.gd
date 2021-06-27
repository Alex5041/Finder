extends PanelContainer


func _ready():
	Info.arcade = true
	if OS.get_name() != "HTML5":
		$Credits/ScrollContainer/HowToPlay.connect(
			"meta_clicked", self, "_on_RichTextLabel_meta_clicked"
		)
	get_node("GameOver/VBoxContainer/Score").text += str(Info.right_action) + "\n"
	if Info.image != null:
		get_node("GameOver/VBoxContainer/Score").add_image(Info.image)
	if Info.game_over:
		get_node("MarginContainer").visible = false
		get_node("GameOver").visible = true
	else:
		get_node("GameOver").visible = false
		get_node("MarginContainer").visible = true
	rect_size = OS.get_window_safe_area().size


func _input(event):
	if (event is InputEventScreenDrag) and $VBoxContainer.visible == true:
		$VBoxContainer/MarginContainer/ScrollContainer.scroll_vertical -= (event.relative.y)


func tap():
	$Tap.set_pitch_scale(randf() / 4 + 0.9)
	$Tap.play()
	pass


func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)


func _on_Start_pressed():
	tap()
	get_node("MarginContainer").visible = false
	get_node("Gamemode").visible = true


func _on_How_to_play_pressed():
	tap()
	get_node("MarginContainer").visible = false
	get_node("VBoxContainer").visible = true


func _on_Leave_pressed():
	tap()
	get_tree().quit()


func _on_Return_pressed():
	tap()
	get_node("VBoxContainer").visible = false
	get_node("MarginContainer").visible = true


func _on_Credits_pressed():
	tap()
	get_node("MarginContainer").visible = false
	get_node("Credits").visible = true


func _on_ReturnFromCredits_pressed():
	tap()
	get_node("Credits").visible = false
	get_node("GameOver").visible = false
	get_node("MarginContainer").visible = true


func _on_FromGamemode_pressed():
	tap()
	get_node("Gamemode").visible = false
	get_node("MarginContainer").visible = true


func _on_Arcade_pressed():
	tap()
	Info.arcade = true
	get_node("Gamemode/MC/RichTextLabel").text = "Arcade: one minute for each round. In some rounds number of request increases. You need to collect points to proceed or upgrade between rounds."


func _on_Zen_pressed():
	tap()
	Info.arcade = false
	get_node("Gamemode/MC/RichTextLabel").text = "Zen: lose after first mistake. Score equals to number of profiles looked through multiplied by number of requests"


func _on_New_pressed():
	tap()
	Info.loaded = false
	get_node("Gamemode").visible = false
	get_node("MarginContainer").visible = true
	if Info.arcade:
		get_tree().change_scene("res://Arcade.tscn")
	else:
		get_tree().change_scene("res://Zen.tscn")


func _on_Try_again_pressed():
	tap()
	get_node("GameOver").visible = false
	get_node("MarginContainer").visible = true
	get_tree().change_scene("res://Zen.tscn")


func _on_IconHeart_pressed():
	if get_node("MarginContainer/VBoxContainer/CC/IconHeart").icon.current_frame == 0:
		$Beat1.set_pitch_scale(randf() / 4 + 0.9)
		$Beat1.play()
	else:
		$Beat2.set_pitch_scale(randf() / 4 + 0.9)
		$Beat2.play()
	get_node("MarginContainer/VBoxContainer/CC/IconHeart").icon.current_frame = (
		(get_node("MarginContainer/VBoxContainer/CC/IconHeart").icon.current_frame + 1)
		% 2
	)


func _on_Continue_pressed():
	tap()
	if Info.can_load() == 1:
		Info.loaded = true
		get_tree().change_scene("res://Zen.tscn")


func _on_Options_pressed():
	tap()
