extends Node2D
export (NodePath) var track_path
onready var track = get_node(track_path)

var track_curve = Curve2D

func _ready():
	update_track_curve()
	pass

func update_track_curve():
	track_curve = track.curve

func get_new_position():
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		return($RayCast2D.get_collision_point())
	else:
		return(null)
	
func get_new_normal():
	$RayCast2D.force_raycast_update()
	return($RayCast2D.get_collision_normal())

func get_closest_track_point(requester_position):
	return track.to_global(track_curve.get_closest_point(track.to_local(requester_position)))
	pass

func get_distance_to_track(requester_position):
	return (requester_position - get_closest_track_point(requester_position)).length()
	pass

