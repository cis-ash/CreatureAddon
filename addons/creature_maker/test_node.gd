tool
extends Button
export (NodePath) var path

func _enter_tree():
	connect("pressed", self, "clicked")


func clicked():
	print("You clicked me!")
