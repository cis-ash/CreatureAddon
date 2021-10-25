extends RigidBody2D
export (float, 0, 1000) var force_per_leg

func _physics_process(delta):
	applied_force = Vector2.ZERO
	for leg in $LegTrack.legs:
		if leg.placed:
			var hip = to_local($LegTrack.get_closest_track_point(leg.global_position))
			var foot = to_local(leg.global_position)
			var direction = (hip - foot).normalized()
			var force_direction = 1.0 - (hip - foot).length() / leg.comfy_distance
			add_force(hip, direction * force_per_leg * force_direction)
			pass
		pass
	pass
