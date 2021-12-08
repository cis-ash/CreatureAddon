extends Node2D
export var eyes_total = 4
export var body_radius = 30.0
export var eye_springiness = 100.0
export var orbit_gravity = 100.0
export var max_distance_spring = 400
export var blink_chance = 1.0
export var speed_damp = 1.0
export var assumed_radius = 150.0
export var rand_force = 100.0


var positions = []
var speeds = []
var forces = []
var eyes = []

func _ready():
	for i in eyes_total:
		positions.append(Vector2.ZERO)
		speeds.append(Vector2.ZERO)
		forces.append(Vector2.ZERO)
	
	for i in eyes_total - 1:
		add_child(get_child(0).duplicate())
	
	eyes = get_children()
	for i in range(positions.size()):
		positions[i] = 150 * sqrt(randf()) * Vector2.RIGHT.rotated(randf() * TAU)
		eyes[i].position = positions[i]
		eyes[i].scale = Vector2.ONE * pow(rand_range(0.75, 1.0), 2) * 0.5
	pass

func move_eyes(world_pos):
	for eye in eyes:
		var direction = world_pos - eye.global_position
		eye.get_child(0).get_child(0).position = clamp(direction.length(), 0.0, 1.0) * 60 * direction.normalized()
	pass

func _physics_process(delta):

	for i in range(eyes.size()):
		
		var pos = positions[i]
		var pull_to_centre = -pos.normalized() * pow(pos.length(), 2) * orbit_gravity
		forces[i] = pull_to_centre
		forces[i] += randf() * rand_force * Vector2.RIGHT.rotated(TAU * randf())
		if pos.length() > body_radius:
			forces[i] -= pos.normalized() * (pos.length() - body_radius) * max_distance_spring
		
		for indx_off in range(eyes.size() - 1):
			var j = wrapi(i + indx_off, 0, eyes.size())
			var pos_other = positions[j]
			var min_dist = assumed_radius * ( eyes[i].scale.x + eyes[j].scale.x)
			var dist = pos - pos_other
			if dist.length() < min_dist:
				forces[i] += (min_dist - dist.length()) * dist.normalized() * eye_springiness * eyes[j].scale.x
			
		
		
		speeds[i] += forces[i] * delta
		speeds[i] *= 1 - delta * speed_damp
		positions[i] += speeds[i] * delta
		
		eyes[i].position = positions[i]
		pass


	for child in get_children():
		var white = child.get_child(0)
		white.scale = lerp(white.scale, Vector2.ONE, delta*10)
		if randf() < blink_chance * delta:
			white.scale = Vector2(1,0)
	
	
	pass
