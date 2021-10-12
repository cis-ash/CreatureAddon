tool
extends Node2D


func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		global_position = get_global_mouse_position()
