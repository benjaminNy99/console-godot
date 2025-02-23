extends Resource

@export var SETTINGS = {
	"addons/console/maximum_historial_records": {
		"value": 50,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,10000,1",
	},
	"addons/console/color_info":{
		"value": Color.WHITE,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	},
	"addons/console/color_error":{
		"value": Color.RED,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	},
	"addons/console/color_warning":{
		"value": Color.YELLOW,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	},
	"addons/console/color_succes":{
		"value": Color.GREEN,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	},
	"addons/console/color_suggestion_inactive":{
		"value": Color.GRAY,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	},
	"addons/console/color_suggestion_active":{
		"value": Color.BLUE,
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
	},
}

func _init() -> void:
	pass
