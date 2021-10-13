tool
extends Node2D

# toggle for in-editor testing
var on = false

var speed : Vector2 = Vector2.ZERO

export (float, 0.0, 10000.0) var gravity = 1000
export (int, 0, 10) var feet 
export (int, 0, 10) var secure_feet

export (float, 0.0, 10000.0) var force_per_foot
export (float, 0.0, 1000.0) var mass

# node to follow
export (NodePath) var target_path
onready var target = get_node(target_path)


func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		on = !on
	
	if on:
		calculate_forces(delta)
	pass

func calculate_forces(delta):
	
	pass
