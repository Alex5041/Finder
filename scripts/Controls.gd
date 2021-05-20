extends Node

signal swiped(direction)
signal swiping(direction)
signal swiped_canceled(start_position)

export(float, 1.0, 1.5) var MAX_DIAGONAL_SLOPE = 1.3
var MIN_DISTANCE = 50

onready var timer = $Timer
var swipe_start_position = Vector2()

func _input(event):
	if not event is InputEventScreenTouch:
		return
	emit_signal("swiping", Vector2(event.position.x, 0))
		#_start_detection(event.position)
	#elif not timer.is_stopped():
		#_end_detection(event.position)

func _start_detection(position):
	swipe_start_position = position
	timer.start()

func _end_detection(position):
	timer.stop()
	var direction = (position - swipe_start_position).normalized()
	if abs(direction.x) + abs(direction.y
	) >= MAX_DIAGONAL_SLOPE or position.distance_to(
		swipe_start_position) < MIN_DISTANCE:
		return
	if abs(direction.x) > abs(direction.y):
		emit_signal("swiped", Vector2(-sign(direction.x), 0.0))
	else:
		emit_signal("swiped,", Vector2(0.0, -sign(direction.y)))


func _on_Timer_timeout():
	emit_signal("swiped_canceled", swipe_start_position)
