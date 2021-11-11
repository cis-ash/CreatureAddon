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
export (float, 0, 1000) var gravity

export (NodePath) var base_path
onready var base = get_node(base_path)



func _ready():
	base.legs.append(self)
	print(base.legs)

func _process(delta):
	
	if placed:
		# home in on target
		speed = lerp(speed, Vector2.ZERO, 3 * slowdown_lerp)
		global_position = lerp(global_position, target, settling_lerp * delta)
		
		# check if out of range and can lift leg
		if base.get_distance_to_track(global_position) > comfy_distance:
			var new_target = base.get_new_target(global_position)
			
			if not new_target == null:
				if base.move_leg():
					# lift leg
					placed = false
					target = new_target["position"]
					new_normal = new_target["normal"]
					speed = normal * liftoff_speed
					pass
				pass
			pass
		pass
		
	
	if not placed:
		# move to new position
		var to_target = target - global_position
		
		speed = lerp(speed, to_target.normalized() * move_speed, delta * lerp_speed)
		speed += to_target.normalized() * move_speed * lerp_acceleration * delta
		speed += Vector2.DOWN * delta * gravity
		position += speed * delta
		
		# check if close enough
		if to_target.length() < tolerance or to_target.length() < delta *  speed.length():
			# place leg
			base.place_leg()
			placed = true
			normal = new_normal
			pass
		pass
	
	
	# draw line to body
	$Line2D.points = PoolVector2Array([Vector2.ZERO, to_local(base.get_closest_track_point(global_position))])
	
	pass
