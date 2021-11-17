extends Node2D
export (NodePath) var surface_path
onready var surface = get_node(surface_path)

var current_dir = Vector2.ZERO
var speed = Vector2.ZERO

export var gravity = 1000
export (float) var dir_clamp

export var friction_per_leg = 3.0
export var force_per_leg = 40.0

var legs
var targets
var ideal_targets
var visual_hands
var visual_legs

export var leg_distance_voluntary = 400.0
export var leg_distance_mandatory = 1000.0
export var attach_distance = 100
export var leg_speed = 1200.0

var legs_planted = 0
export var stable_number_of_legs = 1
export var legs_total = 4

func _ready():
	make_legs_and_targets()
	update_legs_and_targets()
	pass

func _physics_process(delta):
	var current_target = get_global_mouse_position()
	current_dir = (current_target - global_position).clamped(dir_clamp)
	
	$IdealTargets.look_at(current_target + Vector2.UP * gravity * 0.25)
	
	legs_planted = move_legs(delta)
	# accelerate to target
	speed += current_dir * delta * force_per_leg * legs_planted
	# friction
	speed *= 1 - delta * friction_per_leg * legs_planted
	
	
	# apply gravity
	speed += gravity * delta * Vector2.DOWN
	# move body
	global_position += speed * delta
	
	animate_legs(delta)
	
	# look at target
	$EyeManager.move_eyes(current_dir/dir_clamp)
	var debug_info = ""
	debug_info += str(legs_planted)
	
	$Label.text = debug_info
	pass

func make_legs_and_targets():
	for i in legs_total - 1:
		$LegManager.add_child($LegManager.get_child(0).duplicate())
		$RealTargets.add_child($RealTargets.get_child(0).duplicate())
		$Body/VisualLegs.add_child($Body/VisualLegs.get_child(0).duplicate())
		$Body/VisualHands.add_child($Body/VisualHands.get_child(0).duplicate())
		pass
	
	for i in legs_total:
		$IdealTargets.get_child(i).visible = true
	
	print($LegManager.get_children())
	pass

func update_legs_and_targets():
	legs = $LegManager.get_children()
	targets = $RealTargets.get_children()
	ideal_targets = $IdealTargets.get_children()
	visual_legs = $Body/VisualLegs.get_children()
	visual_hands = $Body/VisualHands.get_children()

	pass

func update_real_targets():
	for i in targets.size():
		var closest_point = surface.get_closest_point(ideal_targets[i].global_position)
		if leg_planted(legs[i]) == false or (closest_point - global_position).length() < leg_distance_mandatory:
			targets[i].global_position = closest_point
		pass

func move_legs(delta) -> int:
	update_real_targets()
	var legs_currently_planted = 0
	for i in legs.size():
		
		if not leg_planted(legs[i]):
			# if leg raised - get direction to move leg in
			var to_target = targets[i].global_position - legs[i].global_position
			# move leg
			if to_target.length() < leg_speed * delta:
				legs[i].position += to_target
			else:
				legs[i].position += to_target.normalized() * leg_speed * delta
			pass
		
		
		# calculate distance to ideal position
		var distance_to_leg_target = (legs[i].global_position - targets[i].global_position).length()
		var distance_to_body = (legs[i].global_position - global_position).length()
		
		if leg_planted(legs[i]) and distance_to_leg_target > leg_distance_voluntary:
			# raise leg if far from target and safe to do so
			if legs_planted > stable_number_of_legs:
				raise_leg(legs[i])
				legs_planted -= 1
				pass
			pass
		elif distance_to_body > leg_distance_mandatory and leg_planted(legs[i]):
			# detach leg if its waaaay too far awy
			raise_leg(legs[i])
			legs_planted -= 1
			pass
		elif (not leg_planted(legs[i])) and distance_to_leg_target < attach_distance:
			# plant leg if close enough
			if distance_to_body < leg_distance_mandatory:
				plant_leg(legs[i])
			pass
		
		if leg_planted(legs[i]) == true:
			legs_currently_planted += 1	
			pass
		pass
		
		if distance_to_body > leg_distance_mandatory:
			
			legs[i].global_position = to_global(to_local(legs[i].global_position).normalized() * leg_distance_mandatory)
			legs[i].global_position += randf() * leg_speed * delta * Vector2.RIGHT.rotated(randf() * TAU)
	
	return legs_currently_planted
	

func leg_planted(leg):
	return leg.scale.length() < 2

func raise_leg(leg):
	leg.scale = Vector2.ONE * 2

func plant_leg(leg):
	leg.scale = Vector2.ONE


func animate_legs(delta):
	for i in visual_hands.size():
		visual_hands[i].scale = lerp(visual_hands[i].scale, legs[i].scale/2, delta * 20)
		visual_hands[i].global_position = legs[i].global_position
		visual_legs[i].points = PoolVector2Array([Vector2.ZERO,to_local(legs[i].global_position)])
	
	pass
