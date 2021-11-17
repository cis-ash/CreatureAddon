extends Node2D

func move_eyes(direction):
	for child in get_children():
		child.get_child(0).position = direction * 20
	pass
