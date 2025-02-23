@tool
extends Control


var command_history: Array = []
var history_index: int = -1
var _console: Console

@onready var output: RichTextLabel = $VBoxContainer/HBoxContainer/Output
@onready var promt: LineEdit = $VBoxContainer/Promt


func _ready() -> void:
	_console = Console.new(self)


func _on_promt_text_submitted(new_text: String) -> void:
	_add_to_history(new_text)
	var result = _console.do(new_text)
	
	output.log_message(result)
	promt.text = ""


# Adds a command to the command history and resets the history index.
func _add_to_history(command: String) -> void:
	var max := ProjectSettings.get_setting("addons/console/maximum historial records", 0)
	if max > 0 and command_history.size() >= max:
		command_history.pop_front()
	
	command_history.push_front(command)
	history_index = -1


# Handles keyboard input for the command prompt, specifically for navigating command history.
func _on_promt_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
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
