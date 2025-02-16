@tool
class_name Console
extends Resource


## This class provides a command-line interface within the Godot editor or at runtime.
##
## It allows running predefined commands such as `clear`, `list`, `inspect`, and `exec`.


const COMAND_HELP = "help [comand]"
const COMAND_CLEAR = "clear"
const COMAND_LIST = "list [depth | path_of_nodo [depth]]"
const COMAND_INSPECT = "inspect path_of_node property1 [property2 ...]"
const COMAND_EXEC = "exec ruta_del_nodo metodo|propiedad [parametro1 ...]"

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
		"help":
			result = _comands_help(args)
		"clear":
			result = _comands_clear(args)
		"list":
			result = _comands_list(args)
		"inspect":
			result = _comands_inspect(args)
		"exec":
			result = _comands_exec(args)
		_:
			result = "Error: Incorrect use. Use help for most information"
	
	return result


## Retrieves the root scene of the game or editor, depending on the context.
## [br]
## @return The root scene node, or `null` if not found.
func get_root_scene() -> Node:
	var node := _node.get_tree().current_scene if not Engine.is_editor_hint() else EditorInterface.get_edited_scene_root()
	if node:
		return node
	
	return null


func _comands_help(args: Array) -> String:
	var long := args.size()
	
	var message_help := "Show help for the comands"
	var message_clear := "clear messages of the output"
	var message_list := "List nodes from the root or the specified node, with optional depth"
	var message_inspect := "Show the values ​​of the specified properties of the specified node"
	var message_exec := "Executes a method or gets/sets a property on the specified node"
	
	var result := ""
	match str(long):
		"1":
			result += "Help\n"
			result += "\t- help		-> %s - %s\n" % [COMAND_HELP, message_help]
			result += "\t- clear	-> %s - %s\n" % [COMAND_CLEAR, message_clear]
			result += "\t- list		-> %s - %s\n" % [COMAND_LIST, message_list]
			result += "\t- inspect	-> %s - %s\n" % [COMAND_INSPECT, message_inspect]
			result += "\t- exec		-> %s - %s" % [COMAND_EXEC, message_exec]
		"2":
			match str(args[1]):
				"help":
					result = "Help comand help -> %s - %s" % [COMAND_HELP, message_help]
				"clear":
					result = "Help comand clear -> %s - %s" % [COMAND_CLEAR, message_clear]
				"list":
					result = "Help comand list -> %s - %s" % [COMAND_LIST, message_list]
				"inspect":
					result = "Help comand inspect -> %s - %s" % [COMAND_INSPECT, message_inspect]
				"exec":
					result = "Help comand exec -> %s - %s" % [COMAND_EXEC, message_exec]
				_:
					result = "Help, comand %s does not exists" % [args[1]]
		_:
			return "Error: Incorrect use. Expected format: %s" % [COMAND_HELP]
	
	return result


func _comands_clear(args: Array) -> String:
	var long := args.size()
	
	match str(long):
		"1":
			return ""
	
	return "Error: Incorrect use. Expected format: %s" % [COMAND_CLEAR]


func _comands_list(args: Array) -> String:
	var long := args.size()
	var node_counts := {}
	var node: Node
	var max_depth: int
	
	node = get_root_scene()
	var error := false
	match str(long):
		"1":
			# list child nodes of the root
			max_depth = 1
		"2":
			# list nodes up to a given depth
			if args[1] is int:
				max_depth = args[1]
			# list child nodes of the instantiated node
			elif args[1] is String and node.has_node(args[1]):
				node = node.get_node(args[1])
				max_depth = 1
			else:
				error = true
		"3":
			# list child nodes up to a given depth
			if args[1] is String and args[2] is int:
				node = node.get_node(args[1])
				max_depth = args[2]
			else:
				error = true
		_:
			error = true
	
	if error:
		return "Error: Incorrect use. Expected format: %s" % [COMAND_LIST]
	
	_get_nodes(node, node_counts, 0, max_depth)
	
	# build result in format of list
	var result := "List Nodes [%s] depth: %s" % [node.get_class(), max_depth]
	var entries := []
	for i in node_counts.keys():
		entries.append("\t- %s: %s" % [i, node_counts[i]])
	
	return "%s\n" % [result] + "\n".join(entries) if entries.size() > 0 else result


func _comands_inspect(args: Array) -> String:
	var long := args.size()
	var node := get_root_scene()
	
	var instance: String
	
	var error := false
	if long < 3:
		error = true
	else:
		instance = args[1]
	
	var entries := []
	if not error:
		if node.has_node(instance):
			node = node.get_node(instance)
		else:
			return "The instance %s does not exists." % [instance]
	
		var properties := node.get_property_list()
		for i in args.slice(2):
			if node.get(i) != null or node.get_property_list().any(func(p): return p.name == i):
				entries.append("\t- %s: %s" % [i, node.get(i)])
			else:
				entries.append("\t- %s: not exists" % i)
	
	if error:
		return "Error: Incorrect use. Expected format: %s" % [COMAND_INSPECT]
	
	return "Properties [%s]\n" % [args[1]] + "\n".join(entries) if entries.size() > 0 else ""


func _comands_exec(args: Array) -> String:
	var long := args.size()
	var node := get_root_scene()
	
	var instance = args[1]
	var action = args[2]
	var params = args.slice(3)
	
	var error := false
	if long < 2:
		error = true
	
	if not error:
		if node.has_node(instance):
			node = node.get_node(instance)
		else:
			return "The instance %s does not exists." % [instance]
		
		# for methods
		if node.has_method(action):
			var result = node.callv(action, params)
			return "Execute %s -> %s result: %s" % [instance, action, result]
		
		# for properties
		var value = node.get(action)
		if value != null or node.get_property_list().any(func(p): return p.name == action):
			# only show value of the property
			if params.is_empty():
				return "Instance %s Property %s: %s" % [instance, action, value]
			
			# set value of the property
			if params.size() == 1:
				node.set(action, params[0])
				return "Instance %s Property %s set: %s" % [instance, action, params[0]]
	
	# If you get here, it's an error
	return "Error: Incorrect use. Expected format: %s" % [COMAND_EXEC]


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
