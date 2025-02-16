@tool
extends EditorPlugin


var console_panel


func _enter_tree() -> void:
	console_panel = preload("res://addons/consolegodot/ConsoleGODOT.tscn").instantiate()
	add_control_to_bottom_panel(console_panel, "Console")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(console_panel)
	#console_panel.queve_free()
