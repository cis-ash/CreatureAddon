extends KinematicBody2D
export (float, 0, 1000) var force_per_leg
export (float, 0, 10) var torque_per_leg
export (NodePath) var target_path
onready var target = get_node(target_path)
var to_target = Vector2.ZERO
var speed = Vector2.ZERO
var rotation_speed = 0.0

func _physics_process(delta):
	to_target = target.global_position - global_position
	var angle_to_target = target.global_rotation - global_rotation
	var legs_active = $LegTrack.legs_grounded
	var max_acceleration = legs_active * force_per_leg
	var max_torque = legs_active * torque_per_leg
	
	rotation_speed = lerp_angle(rotation_speed, angle_to_target * max_acceleration, delta * 10)
	speed = lerp(speed, to_target * max_torque, delta * 10)
	
	speed = move_and_slide(speed)
	rotate(rotation_speed * delta)
	

	pass
