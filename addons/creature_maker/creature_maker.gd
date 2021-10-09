tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("MyButton", "Button", preload("test_node.gd"), preload("icon.png"))
	pass


func _exit_tree():
	remove_custom_type("MyButton")
	pass
