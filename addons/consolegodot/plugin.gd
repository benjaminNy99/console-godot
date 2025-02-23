@tool
extends EditorPlugin


var console_panel: Control


func _enter_tree() -> void:
	console_panel = preload("res://addons/consolegodot/ConsoleGODOT.tscn").instantiate()
	add_control_to_bottom_panel(console_panel, "Console")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(console_panel)
	console_panel.queue_free()


func _enable_plugin() -> void:
	var resource_settings = preload("res://addons/consolegodot/settings.gd").new()
	var settings = resource_settings.SETTINGS
	
	for key in resource_settings.SETTINGS.keys():
		if not ProjectSettings.has_setting(key):
			ProjectSettings.set_setting(key, settings[key].value)
		
		ProjectSettings.add_property_info({
			"name": key,
			"type": settings[key].type,
			"hint": settings[key].hint,
			"hint_string": settings[key].hint_string if settings[key].has("hint_string") else "",
		})


func _disable_plugin() -> void:
	var resource_settings = preload("res://addons/consolegodot/settings.gd").new()
	
	for key in resource_settings.SETTINGS.keys():
		var setting = resource_settings.SETTINGS[key]
		if ProjectSettings.has_setting(key):
			ProjectSettings.clear(key)
