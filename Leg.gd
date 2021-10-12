tool
extends Node2D

var on = false
export (bool) var debug_draw
export (NodePath) var foot_path
onready var foot = get_node(foot_path)

export (NodePath) var hip_path
onready var hip = get_node(hip_path)

export (Array, NodePath) var joint_paths
var joints = []
var bone_lengths = []
var total_length = 0.0
export (Array, float) var height_fractions
export (Array, int, "Forward", "Middle", "Backward") var biases
export (float) var facing

export (NodePath) var raycast_path
onready var raycast = get_node(raycast_path)

export (NodePath) var keep_flat_path
onready var keep_flat = get_node(keep_flat_path)


func _ready():
	update_bones()
	pass

func update_bones():
	joints = []
	bone_lengths = []
	total_length = 0.0
	for path in joint_paths:
		joints.append(get_node(path))
		bone_lengths.append(get_node(path).position.length())
		total_length += get_node(path).position.length()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		on = !on
	if on:
		place_joints()

func place_joints():
	var hip_pos = hip.global_position
	var foot_pos = foot.global_position
	raycast.cast_to = foot.position
	raycast.force_raycast_update()
	if raycast.is_colliding():
		foot_pos = raycast.get_collision_point()
		keep_flat.rotation = raycast.get_collision_normal().angle()+TAU/4
	else:
		keep_flat.rotation = 0
	if (hip_pos - foot_pos).length() > total_length:
		foot_pos = hip_pos + total_length * (foot_pos-hip_pos).normalized()
		pass
	var normal = (foot_pos-hip_pos).normalized().rotated(TAU/4)
	var total_v_length = (foot_pos-hip_pos).length()
	var v_length_so_far = 0.0
	var h_offset_so_far = 0.0
	
	for i in range(joints.size()):
		var r_length = bone_lengths[i]
		var v_length = total_v_length*(r_length/total_length)
		var h_offset = sqrt( max( (r_length*r_length) - (v_length*v_length), 0) )
		h_offset_so_far += h_offset*(biases[i]-1)
		v_length_so_far += v_length
		joints[i].global_position = lerp(hip_pos, foot_pos, v_length_so_far/total_v_length)
		joints[i].global_position += normal*h_offset_so_far*facing
		pass
	
#	v_length_so_far = 0.0
#	for i in range(joints.size()):
#		var r_length = bone_lengths[i]
#		var v_length = total_v_length*(r_length/total_length)
#		v_length_so_far += v_length
#		var adjust = lerp(0.0, -0.5*h_offset_so_far, v_length_so_far/total_v_length)
#		joints[i].global_position += normal*adjust*facing
#		pass
#
	pass


