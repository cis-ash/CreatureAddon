extends KinematicBody2D

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		var to_mouse = get_global_mouse_position() - global_position
		move_and_slide(to_mouse * 10)
		pass
	pass
