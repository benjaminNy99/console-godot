@tool
extends RichTextLabel


enum type_message {OUTPUT, SUGGESTION}

@export var type: type_message


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint() and self.type == type_message.OUTPUT:
		var config = ConfigFile.new()
		config.load("res://addons/consolegodot/plugin.cfg")
		
		var color: Color = ProjectSettings.get_setting("addons/console/color_info", Color.WHITE)
		append_text("[color=%s]Console Godot v%s[/color]\n" % [color.to_html(), config.get_value("plugin", "version", null)])


# Logs a message to the console or clears the log if the text is empty.
func log_message(response: Dictionary) -> void:
	var text = response["text"]
	if (text == ""):
		clear()
		return
	
	var color: Color = response["color"]
	var format
	if self.type == type_message.OUTPUT:
		format = "[color=%s]> %s[/color]\n" % [color.to_html(), text]
	else:
		format = "[color=%s][i]%s[/i][/color]\n" % [color.to_html(), text]
	
	append_text(format)
