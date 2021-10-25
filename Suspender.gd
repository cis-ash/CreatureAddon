extends Node2D

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		var to_mouse = get_global_mouse_position() - global_position
		position += to_mouse * 10 * delta
		pass
	pass
