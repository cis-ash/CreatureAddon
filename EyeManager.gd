extends Node2D
export var eyes_total = 4
export var default_eye_spring_radius = 30
export var eye_springiness = 100
export var global_springiness = 100
export var max_distance_spring = 400
export var blink_chance = 1.0


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
	for pos in positions:
		pos = 10 * Vector2.RIGHT.rotated(randf() * TAU)
	print(positions)
	pass

func move_eyes(direction):
	for eye in eyes:
		eye.get_child(0).position = direction * 60
	pass

func _physics_process(delta):
#	for i in eyes_total:
#		var total_force = Vector2.ZERO
#		for j in eyes_total - 1:
#			var id = (i + j)%eyes_total
#			var dist = positions[id] - positions[i]
#			var x = max(default_eye_spring_radius - dist.length(), 0)
#			total_force -= x * eye_springiness * dist.normalized()
#			pass
#
#		if positions[i].length() > max_distance_spring:
#			total_force += (positions[i].length() - max_distance_spring) * positions[i].normalized() * global_springiness
#		forces[i] = total_force
#		pass
#
#	for i in eyes_total:
#		speeds[i] += forces[i] * delta
#		positions[i] += speeds[i] * delta
#		eyes[i].position = positions[i]
	
	$Eye1.scale = lerp($Eye1.scale, Vector2.ONE, delta*10)
	if randf() < blink_chance * delta:
		$Eye1.scale = Vector2(1,0)
	
	
	pass
