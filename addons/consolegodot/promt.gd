@tool
extends LineEdit


@onready var _suggestion: RichTextLabel = $"../HBoxContainer/Suggestion"

var list_suggestions: Array

func _ready() -> void:
	_suggestion.visible = false


func _on_text_submitted(new_text: String) -> void:
	_suggestion.clear()
	_suggestion.visible = false


func _on_text_changed(new_text: String) -> void:
	var args := new_text.split(" ")
	_suggestion.clear()
	
	if new_text.length() > 0:
		match str(args.size()):
			"1":
				self.list_suggestions = _filter_matches(Console.list_comands, args[0])
			"2":
				if args[0] == Console.COMAND_HELP:
					self.list_suggestions = _filter_matches(Console.list_comands, args[1])
				elif args[0] in Console.list_path_of_node:
					self.list_suggestions = _get_node_suggestions(args[1])
				else:
					self.list_suggestions = []
			"3":
				if args[0] == Console.COMAND_INSPECT:
					self.list_suggestions = _get_node_members_suggestions(args[1], args[2], false)
				elif args[0] == Console.COMAND_EXEC:
					self.list_suggestions = _get_node_members_suggestions(args[1], args[2], true)
			_:
				self.list_suggestions = _get_node_members_suggestions(args[1], args[-1], false)
		
		var result := "\n".join(self.list_suggestions)
		_suggestion.visible = true if result.length() > 0 else false
		
		_suggestion.log_message({
			"text": result,
			"color": ProjectSettings.get_setting("addons/console/color_suggestion_inactive", Color.WHITE)
		})
	else:
		_suggestion.visible = false


func _filter_matches(values: Array, value: String) -> Array:
	return values.filter(func(i): return value in i)


func _get_node_suggestions(path_prefix: String) -> Array:
	var root := get_root_scene()
	
	if path_prefix.is_empty():
		return root.get_children().map(func(i): return i.name)
	
	var path_parts := path_prefix.split("/")
	var parent_path := "/".join(path_parts.slice(0, -1))
	var parent_node: Node = root if parent_path.is_empty() else root.get_node(parent_path) as Node
	if not parent_node:
		return []
	
	var nodes := [] if parent_path.is_empty() else [parent_path]
	nodes.append_array(parent_node.get_children().map(func(i): return parent_path + "/" + i.name))
	
	return _filter_matches(nodes, path_prefix)


func _get_node_members_suggestions(node_path: String, filter_text: String, method: bool) -> Array:
	var root := get_root_scene()
	var node := root.get_node(node_path) as Node
	if not node:
		return []
	
	var suggestions := []
	
	var properties := node.get_property_list().map(func(i): return i.name)
	suggestions.append_array(properties if filter_text.is_empty() else _filter_matches(properties, filter_text))
	
	if method:
		var methods := node.get_method_list().map(func(i): return i.name)
		suggestions.append_array(methods if filter_text.is_empty() else _filter_matches(methods, filter_text))
	
	return suggestions


func get_root_scene() -> Node:
	var node := self.get_tree().current_scene if not Engine.is_editor_hint() else EditorInterface.get_edited_scene_root()
	if node:
		return node
	
	return null
