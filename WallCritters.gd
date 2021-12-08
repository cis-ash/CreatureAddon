extends Node2D

export (NodePath) var critter_path
onready var critter = get_node(critter_path)

func _ready():
	$target/AnimationPlayer.play("breathe", -1, 2)

func _physics_process(delta):
	var critter_pos = critter.global_position
	
	if critter_pos.x < -2_000 or critter_pos.x > 31_000 or critter_pos.y < -1_000 or critter_pos.y > 17_000:
		get_tree().reload_current_scene()
	
	pass
	
