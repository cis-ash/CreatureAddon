tool
extends Node2D

# variable that turns on/off in-editor testing
var on = false
export (int, "dont error correct", "error correct") var iter

# target object
export (NodePath) var foot_path
onready var foot = get_node(foot_path)

# root bone of leg
export (NodePath) var hip_path
onready var hip = get_node(hip_path)

# array of leg bones
export (Array, NodePath) var joint_paths
var joints = []
# calculated automatically based on offsets from each other
var bone_lengths = []
# sum of all bone lengths
var total_length = 0.0

# no longer used array for placing knee joints
#export (Array, float) var height_fractions

# bias for joint bend directions
export (Array, int, "Forward", "Middle", "Backward") var biases

# variable to simulate 3d rotation along leg axis
# 1.0 = facing right
# -1.0 = facing left
export (float, -1.0, 1.0) var facing

# raycast that determines where the leg goes
export (NodePath) var raycast_path
onready var raycast = get_node(raycast_path)

# joint that should remain parallel to the ground
export (NodePath) var keep_flat_path
onready var keep_flat = get_node(keep_flat_path)

var touching_ground = false

export (Array, Curve) var leg_factors

# builds bones when node is loaded
# reload saved scene to rebuild after code change/ length alteration
func _ready():
	update_bones()
	pass

func update_bones():
	raycast = get_node(raycast_path)
	keep_flat = get_node(keep_flat_path)
	foot = get_node(foot_path)
	hip = get_node(hip_path)
	
	joints = []
	bone_lengths = []
	total_length = 0.0
	
	for path in joint_paths:
		joints.append(get_node(path))
		bone_lengths.append(get_node(path).position.length())
		total_length += get_node(path).position.length()

# toggles in editor processing on/off
# if on - run joint placer
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		on = !on
		if on:
			update_bones()
	
	if on:
		place_joints_recursively(foot.global_position, iter)
		
func place_joints_recursively(where, iterations):
	var toe = joints[joints.size()-1]
	place_joints(where)
	for i in range(iterations):
		var error = get_angle_to(toe.global_position) - get_angle_to(where)
		print(error)
		var corrected_local = to_local(where).rotated(-error)
		var rescaled_local = corrected_local*cos(error)
		place_joints(to_global(rescaled_local))
		where = to_global(rescaled_local)

func place_joints(target):
	var hip_pos = hip.global_position
	var foot_pos = target
	
	# cast ray to target
	raycast.cast_to = raycast.to_local(foot.global_position)
	raycast.force_raycast_update()
	
	
	keep_flat.scale.x = facing
	var allowed_length 
	if raycast.is_colliding() and (raycast.get_collision_point() - hip_pos).length()<total_length:
		# if ground within range 
		# place foot on ground
#		foot_pos = raycast.get_collision_point()
		allowed_length = to_local(raycast.get_collision_point()).length()
		# rotate foot to be parallel to ground
		keep_flat.rotation = raycast.get_collision_normal().angle()+TAU/4
		
		touching_ground = true
	else:
		# if no ground within range
		# rotate foot to the midair angle
		keep_flat.rotation = 0
		allowed_length = total_length
		touching_ground = false
	
	# if foot further than should be possible
	# assume it is as far as it can possibly be
	if (hip_pos - foot_pos).length() > allowed_length:
		foot_pos = hip_pos + allowed_length * (foot_pos-hip_pos).normalized()
	
	# get vector perpendicular to leg axis
	var normal = (foot_pos-hip_pos).normalized().rotated(TAU/4)
	
	# get distance from hip to foot
	var total_v_length = (foot_pos-hip_pos).length()
	
	var v_length_so_far = 0.0
	var h_offset_so_far = 0.0
	
	var fraction_pos = total_v_length/total_length
#	print(fraction_pos)
	var factor_sum = 0.0
	for i in range(leg_factors.size()):
		factor_sum += leg_factors[i].interpolate(fraction_pos)*bone_lengths[i]
#	print(factor_sum)
	# run code on all joints
	for i in range(joints.size()):
		# length of current bone
		var r_length = bone_lengths[i]
		
		# length of current bone projected onto leg axis
		var v_length = total_v_length*leg_factors[i].interpolate(fraction_pos)*bone_lengths[i]/factor_sum
		
		# distance from joint to leg axis
		var h_offset = sqrt( max( (r_length*r_length) - (v_length*v_length), 0) )
		
		# offset joint relative to previous perpendicular to leg axis
		h_offset_so_far += h_offset*(biases[i]-1)
		
		v_length_so_far += v_length
		
		# place joint along leg
		joints[i].global_position = lerp(hip_pos, foot_pos, v_length_so_far/total_v_length)
		# offset perpendicular to leg
		joints[i].global_position += normal*h_offset_so_far*facing
		pass
	
	pass


