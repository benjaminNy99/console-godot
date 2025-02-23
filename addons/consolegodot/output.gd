@tool
extends RichTextLabel


enum type_message {OUTPUT, SUGGESTION}

@export var type: type_message


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint() and type_message.OUTPUT:
		var config = ConfigFile.new()
		config.load("res://addons/consolegodot/plugin.cfg")
		
		append_text("Console Godot v%s\n" % [config.get_value("plugin", "version", null)])


# Logs a message to the console or clears the log if the text is empty.
func log_message(text: String) -> void:
	if (text == ""):
		clear()
		return
	
	var format := "> %s\n" if self.type == type_message.OUTPUT else "%s\n"
	
	append_text(format % [text])
