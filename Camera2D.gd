extends Camera2D
export(NodePath) var target_path
onready var target = get_node(target_path)
var speed = Vector2.ZERO

export var enthusiasm = 1.0
export var rate = 1.0


func _physics_process(delta):
	
	speed = lerp(speed, (target.global_position - global_position) * enthusiasm, delta * rate)
#	print(global_position)
	global_position += speed * delta
	pass
