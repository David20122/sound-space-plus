extends Resource
class_name Settings

const SettingsList = [
	["first_time",Type.BOOLEAN,true],
	["approach",Type.CATEGORY,[
		["time",Type.FLOAT,1.0],
		["distance",Type.FLOAT,50.0],
		["rate",Type.FLOAT,50.0]
	]],
	["parallax",Type.FLOAT,1.0],
	["assets",Type.CATEGORY,[
		["block",Type.STRING,"cube"],
		["world",Type.STRING,"tunnel"]
	]],
	["colorset",Type.ARRAY,["#ff0000","#00ffff"]],
	["volume",Type.CATEGORY,[
		["master",Type.FLOAT,0.5],
		["master_menu",Type.FLOAT,1.0],
		["menu_music",Type.FLOAT,1.0],
		["menu_sfx",Type.FLOAT,1.0],
		["master_game",Type.FLOAT,1.0],
		["game_music",Type.FLOAT,1.0],
		["game_sfx",Type.FLOAT,1.0]
	]],
	["controls",Type.CATEGORY,[
		["sensitivity",Type.CATEGORY,[
			["mouse",Type.FLOAT,1.0]
		]]
	]]
]

enum Type {
	BOOLEAN,
	INT,
	FLOAT,
	STRING,
	ARRAY,
	CATEGORY
}
func validate_type(value:Variant,type:int):
	match type:
		Type.BOOLEAN:
			return value is bool
		Type.INT:
			return value is int
		Type.FLOAT:
			return value is float
		Type.STRING:
			return value is String
		Type.ARRAY:
			return value is Array
		Type.CATEGORY:
			return value is Dictionary
	return false

var data:Dictionary = {}

func validate(origin:Dictionary,template:Array):
	var new = {}
	for setting in template:
		var original = origin.get(setting[0],null)
		var valid = validate_type(original,setting[1])
		if setting[1] == Type.CATEGORY:
			if !valid:
				original = {}
			new[setting[0]] = validate(original,setting[2])
			continue
		if !valid:
			new[setting[0]] = setting[2]
		else:
			new[setting[0]] = original
	return new
func validate_self(_data:Dictionary=data):
	data = validate(_data,SettingsList)

func _init(_data:Dictionary={}):
	validate_self(_data)

func _get(property):
	assert(data.has(property))
	return data.get(property)
