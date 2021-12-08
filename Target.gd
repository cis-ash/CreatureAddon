extends Node2D

var distance_to_critter = 0.0
var speed = Vector2.ZERO

var max_speed = 4000.0

func _physics_process(delta):
	rotate(delta * 3)
	
	if Input.is_action_pressed("mouse"):
		global_position = lerp(
				global_position, 
				get_global_mouse_position(), 
				delta * 12)
		pass
	
	var intent = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		intent += Vector2.RIGHT
	if Input.is_action_pressed("ui_left"):
		intent += Vector2.LEFT
	if Input.is_action_pressed("ui_down"):
		intent += Vector2.DOWN
	if Input.is_action_pressed("ui_up"):
		intent += Vector2.UP

	speed = lerp(speed, intent * max_speed, delta * 5)
	global_position += speed * delta
	
	modulate = lerp(Color(1,1,1,0), Color(1,1,1,1), clamp( distance_to_critter/200 - 3.0, 0.0, 1.0))
	pass
	
	
	
