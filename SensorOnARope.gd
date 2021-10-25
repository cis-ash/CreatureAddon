extends PathFollow2D



func get_intersection():
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		return {"position": $RayCast2D.get_collision_point(), "normal": $RayCast2D.get_collision_normal()}
	else:
		return null


func set_distance(distance):
	$RayCast2D.cast_to = Vector2.DOWN * distance
