extends Node2D

var placed = false
onready var target = global_position
var normal = Vector2.UP
var new_normal = Vector2.UP
var speed = Vector2.ZERO

export (float, 0, 1000) var comfy_distance
export (float, 0, 100) var tolerance

export (float, 0, 10000) var liftoff_speed
export (float, 0, 10000) var move_speed
export (float, 0, 10) var lerp_speed
export (float, 0, 10) var lerp_acceleration
export (float, 0, 10) var slowdown_lerp
export (float, 0, 10) var settling_lerp
export (NodePath) var base_path
export (float, 0, 1000) var gravity

onready var base = get_node(base_path)

func _process(delta):
	
	if placed:
		speed = lerp(speed, Vector2.ZERO, 3 * slowdown_lerp)
		global_position = lerp(global_position, target, settling_lerp * delta)
		
		# idle and check if still in range
#		var to_base = base.global_position - global_position
		if base.get_distance_to_track(global_position) > comfy_distance:
			var new_target = base.get_new_position()
			if not new_target == null:
				print("lifted")
				# check if there is a new target
				# lift leg
				placed = false
				target = new_target
				new_normal = base.get_new_normal()
				speed = normal * liftoff_speed
		pass
	
	if not placed:
		# move to new position
		var to_target = target - global_position
		speed = lerp(speed, to_target.normalized() * move_speed, delta * lerp_speed)
		speed += to_target.normalized() * move_speed * lerp_acceleration * delta
		position += speed * delta
		speed += Vector2.DOWN * delta * gravity
		
		if to_target.length() < tolerance or to_target.length() < delta *  speed.length():
			print("placed")
			# check if arrived
			# place leg
			placed = true
			normal = new_normal
		pass
	$Line2D.points = PoolVector2Array([Vector2.ZERO, to_local(base.get_closest_track_point(global_position))])
	
	pass
