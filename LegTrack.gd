extends Path2D

export (int, 1, 100) var raycast_count

var legs : Array = []
export (float, 0.0, 1.0) var legs_needed_percent
var legs_grounded = 0

var raycasts : Array = []
var intersections : Array = []

export (PackedScene) var raycast_on_string



func _ready():
	for i in range(raycast_count):
		add_raycast()
		pass
	
	space_out_raycasts()
	pass


func move_leg():
	if legs_grounded > legs.size() * legs_needed_percent:
		legs_grounded -= 1
		return true
	else:
		return false


func place_leg():
	legs_grounded += 1


func add_raycast():
	var new_raycast = raycast_on_string.instance()
	add_child(new_raycast)
	raycasts.append(new_raycast)
	pass


func space_out_raycasts():
	var i = 0
	for raycast in raycasts:
		raycast.unit_offset = i * 1.0 / raycasts.size()
		i += 1
		pass
	pass


func get_new_target(requester_position):
	refresh_intersections()
	return get_closest_intersection()
	pass


func refresh_intersections():
	intersections = []
	for raycast in raycasts:
		intersections.append(raycast.get_intersection())
		pass
	pass

func get_closest_intersection():
	var closest_intersection = {"distance": INF, "position": null}
	for intersection in intersections:
		if not intersection == null:
			if intersection["distance"] < closest_intersection["distance"]:
				closest_intersection = intersection
				pass
			pass
		pass
	
	
	if closest_intersection["position"] == null:
		return null
	else:
		return closest_intersection
	
	pass


func get_closest_track_point(requester_position):
	return to_global(curve.get_closest_point(to_local(requester_position)))
	pass


func get_distance_to_track(requester_position):
	return (requester_position - get_closest_track_point(requester_position)).length()
	pass

