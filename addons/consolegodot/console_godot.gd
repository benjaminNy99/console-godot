@tool
extends Control


var command_history: Array = []
var history_index: int = -1
var _console: Console

@onready var output = get_node("VBoxContainer/Output")
@onready var promt = get_node("VBoxContainer/Promt")


func _ready() -> void:
	_console = Console.new(self)
	
	var node := _console.get_root_scene()
	if not node:
		output.log_message("Not exists node root")


func _on_promt_text_submitted(new_text: String) -> void:
	_add_to_history(new_text)
	var result := _console.do(new_text)
	
	output.log_message(result)
	promt.text = ""


# Adds a command to the command history and resets the history index.
func _add_to_history(command: String) -> void:
	command_history.append(command)
	history_index = -1


# Handles keyboard input for the command prompt, specifically for navigating command history.
func _on_promt_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			var size := command_history.size()
			if size > 0:
				if history_index == -1:
					history_index = size - 1
				elif  history_index > 0:
					history_index -= 1
				
				var history: String = command_history[history_index]
				promt.text = history
				promt.call_deferred("set_caret_column", history.length())
		elif event.keycode == KEY_DOWN:
			var size := command_history.size()
			if size > 0:
				history_index += 1
				if history_index >= size:
					history_index = -1
					promt.text = ""
				else:
					promt.text = command_history[history_index]
					promt.caret_column = promt.text.length()
