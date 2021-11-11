extends Node2D
export (NodePath) var surface_path
onready var surface = get_node(surface_path)
var current_dir = Vector2.ZERO
var speed = Vector2.ZERO
export (float) var dir_clamp

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var current_target = surface.get_closest_point(get_global_mouse_position())
	current_dir = (current_target - global_position).clamped(dir_clamp)
	speed = lerp(speed, current_dir * 20, delta * 10)
	global_position += speed * delta
	$Eye/Iris.position = 10 * current_dir / dir_clamp
	$Eye.position = 20 * current_dir / dir_clamp
	pass
