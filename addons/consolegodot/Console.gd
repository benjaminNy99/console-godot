@tool
class_name Console
extends Resource


## This class provides a command-line interface within the Godot editor or at runtime.
##
## It allows running predefined commands such as `clear`, `list`, `inspect`, and `exec`.


var _node: Node


## Initializes the Console with a reference to the root node.
## [br]
## @param node The root node of the scene tree.
func _init(node: Node) -> void:
	_node = node


## Executes a command string by parsing it and calling the corresponding internal method.
## [br]
## @param command A string representing the command to execute.[br]
## @return The result of the command execution as a string.
func do(command: String) -> String:
	var args := _parse_params(command.split(" "))
	var result: String
	
	match args[0]:
		"clear":
			result = _comands_clear(args)
		"list":
			result = _comands_list(args)
		"inspect":
			result = _comands_inspect(args)
		"exec":
			result = _comands_exec(args)
		_:
			result = "command"
	
	return result


## Retrieves the root scene of the game or editor, depending on the context.
## [br]
## @return The root scene node, or `null` if not found.
func get_root_scene() -> Node:
	var node := _node.get_tree().current_scene if not Engine.is_editor_hint() else EditorInterface.get_edited_scene_root()
	if node:
		return node
	
	return null


func _comands_clear(args: Array) -> String:
	var long := args.size()
	
	match str(long):
		"1":
			return ""
	
	return "do"


func _comands_list(args: Array) -> String:
	var long := args.size()
	var node_counts := {}
	var node: Node
	var max_depth: int
	
	node = get_root_scene()
	match str(long):
		"1":
			max_depth = 1
		"2":
			if args[1] is int:
				max_depth = args[1]
			elif args[1] is String:
				node = node.get_node(args[1])
				max_depth = 1
		"3":
			if args[1] is String:
				node = node.get_node(args[1])
				if args[2] is int:
					max_depth = args[2]
	
	_get_nodes(node, node_counts, 0, max_depth)
	
	var result := "List Nodes [%s] depth: %s" % [node.get_class(), max_depth]
	var entries := []
	for i in node_counts.keys():
		entries.append("\t- %s: %s" % [i, node_counts[i]])
	
	return "%s\n" % [result] + "\n".join(entries) if entries.size() > 0 else result


func _comands_inspect(args: Array) -> String:
	var long := args.size()
	var node: Node
	
	if long < 3:
		return ""
	
	node = get_root_scene().get_node(args[1])
	if not node:
		return "The node not exists."
	
	var properties := node.get_property_list()
	var entries := []
	for i in args.slice(2):
		if node.get(i) != null or node.get_property_list().any(func(p): return p.name == i):
			entries.append("\t- %s: %s" % [i, node.get(i)])
		else:
			entries.append("\t- %s: not exists" % i)
	
	return "Properties [%s]\n" % [args[1]] + "\n".join(entries) if entries.size() > 0 else ""


func _comands_exec(args: Array) -> String:
	var long := args.size()
	var node: Node
	
	var instance = args[1]
	var action = args[2]
	var params = args.slice(3)
	
	if long < 2:
		return ""
	
	node = get_root_scene().get_node(instance)
	if not node:
		return "The node not exists."
	
	if node.has_method(action):
		var result = node.callv(action, params)
		return "Execute %s -> %s result: %s" % [instance, action, result]
	
	var value = node.get(action)
	if value != null or node.get_property_list().any(func(p): return p.name == action):
		if params.is_empty():
			return "Instance %s Property %s: %s" % [instance, action, value]
		
		if params.size() == 1:
			node.set(action, params[0])
			return "Instance %s Property %s set: %s" % [instance, action, params[0]]
	
	return ""


# Parses an array of parameters, converting strings to their appropriate data types when possible.
func _parse_params(params: Array) -> Array:
	return params.map(func(p):
		if p.is_valid_int(): return int(p)
		elif p.is_valid_float(): return float(p)
		elif p.to_lower() == "true": return true
		elif p.to_lower() == "false": return false
		return p)


# Recursively traverses a node tree, counts nodes by their class type, and stores the results.
func _get_nodes(node: Node, node_counts: Dictionary, depth: int, max_depth: int) -> void:
	if (depth > max_depth):
		return
	
	if depth > 0: # it's not the root
		var type_name = node.get_class()
		if not node_counts.has(type_name):
			node_counts[type_name] = 0
		
		node_counts[type_name] += 1
	
	# Recursively process all child nodes.
	for child in node.get_children():
		_get_nodes(child, node_counts, depth + 1, max_depth)
