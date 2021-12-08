extends Node2D

# surface is the nav-mesh parente, often asked where is the closest valid spot
export (NodePath) var surface_path
onready var surface = get_node(surface_path)

# current_dir is the direction Navigator is moving in
var current_dir = Vector2.ZERO
var speed = Vector2.ZERO

export var gravity = 1000
# clamps current_dir to a value to limit its top speed
# in a way that does eliminate the slowdown on approach
export (float) var dir_clamp

# friction slows navigator down proportional to current speed
export var friction_total = 6.0
# force accelerates navigator to their target
export var force_total = 100.0

# arrays containing references to nodes responsible for leg logic
var legs
var targets
var ideal_targets
#var visual_hands
var visual_legs

# voluntarily lift leg when further than this from target and it is permitted
export var leg_distance_voluntary = 400.0
# length of leg, forcefully lifts it off when distance is reached
export var leg_distance_mandatory = 1000.0
# plant leg on surface when this close to target
export var attach_distance = 100
# move lifted legs to their targets with this linear speed
export var leg_speed = 1200.0

# updated when legs are moved
var legs_planted = 0
# if more than this number of legs are attached - another one can be lifted
export var stable_number_of_legs = 1
# how many legs to spawn
export var legs_total = 4
export var nodes_per_leg = 5
export var preferred_damping = 2

# arrays of pool vector2 arrays containing info necessary for visual side of legs
var rope_nodes_positions = []
var rope_nodes_speeds = []


export var rope_fraction_idle = 0.5
export var rope_springiness = 10000.0
export var rope_damping = 3.0
export var rope_timesteps = 5
func _ready():
	# spawn desired number of legs and do necessary setup
	make_legs_and_targets()
	# save references to nodes relevant to leg operation for easier access
	update_legs_and_targets()
	pass

func _physics_process(delta):
	
	var old_speed = speed
	# find current target and clamp movement toward it 
	# using mouse as target for debug purposes
	var current_target = get_global_mouse_position()
	current_dir = (current_target - global_position).clamped(dir_clamp)
	
	# node containing ideal positions for all legs is rotated to where they will be needed
	# (they will be needed ahead and a bit up)
	$IdealTargets.look_at(current_target + Vector2.UP * gravity * 0.25)
	
	# move legs and update how many are attached
	legs_planted = move_legs(delta)
	
	# accelerate to target based on number of legs attached
	speed += current_dir * delta * force_total * legs_planted / legs_total
	# decelerate based on number of legs attached
	speed *= 1 - delta * friction_total * legs_planted / legs_total

	# apply gravity
	speed += gravity * delta * Vector2.DOWN
	# move body
	global_position += speed * delta
	
	var acceleration = (speed - old_speed)/max(delta, 0.001)
	# move visual components of legs
#	animate_legs(delta)
	for i in range(legs_total):
		for j in range(rope_timesteps):
			simulate_rope(i, Vector2.ZERO, to_local(legs[i].global_position), -acceleration + gravity * Vector2.DOWN, delta/rope_timesteps)
		visual_legs[i].points = rope_nodes_positions[i]
	
	# look at target
	$EyeManager.move_eyes(current_target)
	
	pass

func make_legs_and_targets():
	# make rope relevant arrays empty to avoid mess ups
	rope_nodes_positions = []
	rope_nodes_speeds = []
	
	# duplicate first children in leg relevant nodes
	for i in legs_total - 1:
		$LegManager.add_child($LegManager.get_child(0).duplicate())
		$RealTargets.add_child($RealTargets.get_child(0).duplicate())
		$Body/VisualLegs.add_child($Body/VisualLegs.get_child(0).duplicate())
#		$Body/VisualHands.add_child($Body/VisualHands.get_child(0).duplicate())
		pass
	
	# make ideal targets that will be used visible
	# append enough empty pool vector2 arrays for all leg ropes
	var empty_array = []
	for i in nodes_per_leg:
		empty_array.append(Vector2.ZERO)
	for i in legs_total:
		$IdealTargets.get_child(i).visible = true
		rope_nodes_positions.append(PoolVector2Array(empty_array))
		rope_nodes_speeds.append(PoolVector2Array(empty_array))
	pass

func update_legs_and_targets():
	# done for speed and ease of acces later on
	legs = $LegManager.get_children()
	targets = $RealTargets.get_children()
	ideal_targets = $IdealTargets.get_children()
	visual_legs = $Body/VisualLegs.get_children()
#	visual_hands = $Body/VisualHands.get_children()
	pass

func update_real_targets():
	# real targets are what legs actually attempt to follow
	for i in targets.size():
		# nearest point on grabable surface
		var closest_point = surface.get_closest_point(ideal_targets[i].global_position)
		
		# only move to closest point if it is in range 
		# (or if the leg is raised, this part is a failsafe for when you fall off)
		if leg_planted(legs[i]) == false or (closest_point - global_position).length() < leg_distance_mandatory:
			targets[i].global_position = closest_point
		pass
	pass

func move_legs(delta : float) -> int:
	update_real_targets()
	
	# this is the return variable, internally the info from past frame is updated and used
	var legs_currently_planted = 0
	
	for i in legs.size():
		if not leg_planted(legs[i]):
			# if leg raised - get direction to move leg in
			var to_target = targets[i].global_position - legs[i].global_position
			
			# move leg to target, if close enough - go there directly
			# this is done to avoid overshooting repeatedly at high leg speed / high delta
			if to_target.length() < leg_speed * delta:
				legs[i].position += to_target
			else:
				legs[i].position += to_target.normalized() * leg_speed * delta
			pass
		
		
		# calculate distance to ideal position and body
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
			# detach leg if its further away than physically possible
			raise_leg(legs[i])
			legs_planted -= 1
			pass
		elif (not leg_planted(legs[i])) and distance_to_leg_target < attach_distance:
			# plant leg if close enough
			if distance_to_body < leg_distance_mandatory:
				plant_leg(legs[i])
			pass
		
		# count all planted legs for return variable
		if leg_planted(legs[i]) == true:
			legs_currently_planted += 1	
			pass
		pass
		
		if distance_to_body > leg_distance_mandatory:
			# if further away than possible:
			# move closer
			# flail around in panic
			legs[i].global_position = to_global(to_local(legs[i].global_position).normalized() * leg_distance_mandatory)
			legs[i].global_position += randf() * leg_speed * delta * Vector2.RIGHT.rotated(randf() * TAU) / 4
	
	return legs_currently_planted
	
	
# i did not want to add an extra script just for storing variables to all legs
# this also doubles as looking kinda cool

func leg_planted(leg : Node2D):
	return leg.scale.length() < 2

func raise_leg(leg : Node2D):
	leg.scale = Vector2.ONE * 2

func plant_leg(leg : Node2D):
	leg.scale = Vector2.ONE


#func animate_legs(delta : float):
#
#	# hands are leg tips
#	for i in visual_hands.size():
#		# scaled to approach leg scale (appearance of liftin and placing)
#		visual_hands[i].scale = lerp(visual_hands[i].scale, legs[i].scale/2, delta * 20)
#		# they are moved to where the legs are
#		visual_hands[i].global_position = legs[i].global_position
#
#	pass


# rope physics calculated here
func simulate_rope(
		index : int,
		new_start_pos : Vector2, 
		new_end_pos : Vector2, 
		acceleration : Vector2, 
		delta : float
		):
	
	var empty_array = []
	for i in nodes_per_leg:
		empty_array.append(Vector2.ZERO)
	
	# create local copy of needed info
	var new_positions = rope_nodes_positions[index]
	var new_speeds = rope_nodes_speeds[index]
	# create force array of needed size
	var new_forces = PoolVector2Array(empty_array)
	# calcualte max size of rope segments
	var max_segment_length = leg_distance_mandatory / (nodes_per_leg - 1)
	# place first and last points where they need to be
	new_positions[0] = new_start_pos
	new_positions[nodes_per_leg - 1] = new_end_pos
	
	# calculate lengths
	var segment_lengths = PoolVector2Array()
	# move forward through chain
	for i in range(0, nodes_per_leg-1):
		segment_lengths.append(new_positions[i+1] - new_positions[i])
		pass

	
	for i in segment_lengths.size():
		var x = segment_lengths[i].length() - max_segment_length * rope_fraction_idle
		var force = x * rope_springiness
		new_forces[i] += segment_lengths[i].normalized() * force
		new_forces[i+1] += -segment_lengths[i].normalized() * force
		pass
	
	# apply acceleration to speeds
	for i in range(new_speeds.size()):
		new_speeds[i] += acceleration * delta
		new_speeds[i] += new_forces[i] * delta
		new_speeds[i] *= 1 - delta * rope_damping
		pass
	
	# make sure first and last nodes are stationary
	new_speeds[0] = Vector2.ZERO
	new_speeds[nodes_per_leg - 1] = Vector2.ZERO
	
	# apply speeds to positions
	for i in nodes_per_leg:
		new_positions[i] += new_speeds[i] * delta	
		pass
	
	rope_nodes_positions[index] = new_positions
	rope_nodes_speeds[index] = new_speeds
	
	pass
