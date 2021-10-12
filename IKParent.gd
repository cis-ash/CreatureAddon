# usage: attach to a node2d
# the first child will be the base joint
# the first child of that child will be the next joint
# etc, the first child is always the joint. The
# last child will be the end effector
# move the joint along the x axis to set the length of the limb
# e.g:
# v Base, pos = any
#   v Joint, local pos = 0, 0
#     v Joint, local pos = 0, 20
# 		v End, local pos = 0, 30

extends Node2D

var joints = []
var total_length = 0
var end_effector = null
var target = Vector2(0, 0)

func _ready():
	load_limb_info()
	pass

func load_limb_info():
	var obj = get_child(0)
	while obj.get_child_count() > 0:
		var ch = obj.get_child(0)
		joints.append([obj, ch.position, ch])
		total_length += ch.position.x
		obj = ch
	end_effector = obj

func _process(delta):
	target = get_global_mouse_position()
	calc_ik()
	update()

func calc_ik():
	var offset = target - global_position
	if offset.length() > total_length:
		for joint in joints:
			joint[0].rotation = 0
			#joint[2].position = joint[1]
		var r = atan2(offset.y, offset.x)
		joints[0][0].global_rotation = r
	else:
		for i in range(15):
			end_to_root()
			root_to_end()

func constrain_limb(var limb):
	var a_min = -180
	var a_max = 0
	var r = limb.rotation_degrees
	if r >= a_min and r <= a_max:
		return
	else:
		limb.rotation_degrees = clamp(limb.rotation_degrees, a_min, a_max)
	
#	var max_diff = 180 - a_max
#	var min_diff = 180 + a_min
#	if r < 0:
#		if 180 + r + max_diff < abs(r - a_min):
#			limb.rotation = a_max
#		else:
#			limb.rotation = a_min
#	else:
#		if r - a_max < 180 - r + min_diff:
#			limb.rotation = a_max
#		else:
#			limb.rotation = a_min
	
	limb.rotation_degrees = clamp(limb.rotation_degrees, 0, 90)

func end_to_root():
	var tar = target
	var joint_dup = joints.duplicate()
	joint_dup.invert()
	
	for joint in joint_dup:
		var base = joint[0]
		var end_point = joint[1]
		var next = joint[2]
		etr_set_limb(base, end_point, tar, next)
		tar = joint[0].global_position
	
	end_effector.global_position = target

#limb = base of limb
#end = local end position of limb
#tar = target position of limb
#next = next limb segment
func etr_set_limb(var limb, var end, var tar, var next):
	var next_st_pos = next.global_position
	var next_st_rot = next.global_rotation
	
	#rotate limb to face point
	var t_pos = tar - limb.global_position
	var r = atan2(t_pos.y, t_pos.x)
	limb.global_rotation = r
	
	constrain_limb(limb)
	
	#move limb so end is on target_point
	limb.global_position += tar - limb.to_global(end)
	
	next.global_position = next_st_pos
	next.global_rotation = next_st_rot

var c = 0
func root_to_end():
	var tar = global_position
	for joint in joints:
		var base = joint[0]
		var next = joint[2]
		rte_set_limb(base, tar, next)
		tar = joint[0].to_global(joint[1])
	


func rte_set_limb(limb, limb_tar, next):
	var next_st_pos = next.global_position
	var next_st_rot = next.global_rotation
	
	limb.global_position = limb_tar
	var off = next_st_pos - limb.global_position
	var r = atan2(off.y, off.x)
	limb.global_rotation = r
	
	#TODO constraints
	#constrain_limb(limb)
	
	next.global_position = next_st_pos
	next.global_rotation = next_st_rot

func _draw():
	#var col = Color(1, 1, 1)
	var j_count = joints.size()
	for i in range(j_count):
		var joint = joints[i][0]
		var j_pos = joint.global_position
		var c_pos = joint.to_global(joints[i][1])
		var col = Color(i * 1.0 / j_count, 0, 0)
		
		draw_circle(to_local(j_pos), 5, col)
		draw_line(to_local(j_pos), to_local(c_pos), col, 5)
	
	draw_circle(to_local(end_effector.global_position), 10, Color(1, 1, 0))
