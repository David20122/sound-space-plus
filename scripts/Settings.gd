extends Resource
class_name Settings

func update():
	# Update approach rates
	var approach = data.approach
	match approach.mode:
		Settings.ApproachMode.DISTANCE_TIME:
			approach.rate = approach.distance / approach.time
		Settings.ApproachMode.DISTANCE_RATE:
			approach.time = approach.distance / approach.rate
		Settings.ApproachMode.RATE_TIME:
			approach.distance = approach.rate * approach.time
	# Update volumes
	var volume = data.volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),linear_to_db(volume.master))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Menu"),linear_to_db(volume.master_menu))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Menu Music"),linear_to_db(volume.menu_music))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Menu SFX"),linear_to_db(volume.menu_sfx))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Game"),linear_to_db(volume.master_game))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Game Music"),linear_to_db(volume.game_music))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Game SFX"),linear_to_db(volume.game_sfx))
	# Window mode
	var window = ssp.get_window()
#	window.borderless = data.window_mode != WindowMode.WINDOWED
	match data.window_mode:
		WindowMode.WINDOWED:
			window.mode = Window.MODE_WINDOWED
		WindowMode.BORDERLESS:
			window.mode = Window.MODE_FULLSCREEN
		WindowMode.FULLSCREEN:
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	# FPS limit
	ssp.get_tree().fps_limit = data.fps_limit

enum WindowMode {
	WINDOWED,
	BORDERLESS,
	FULLSCREEN
}
enum ApproachMode {
	DISTANCE_TIME,
	DISTANCE_RATE,
	RATE_TIME
}
const SettingsList = [
	["first_time",Type.BOOLEAN,true],
	["window_mode",Type.INT,WindowMode.WINDOWED],
	["fps_limit",Type.INT,0],
	["approach",Type.CATEGORY,[
		["time",Type.FLOAT,1.0],
		["distance",Type.FLOAT,50.0],
		["rate",Type.FLOAT,50.0],
		["mode",Type.INT,ApproachMode.RATE_TIME]
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
		]],
		["drift",Type.BOOLEAN,false],
		["spin",Type.BOOLEAN,false]
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
		if setting[1] == Type.INT and original is float:
			original = int(original)
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
	update()

var ssp:SoundSpacePlus
func _init(_ssp:SoundSpacePlus=null,_data:Dictionary={}):
	ssp = _ssp
	validate_self(_data)

func _get(property):
	if !data.has(property):
		print("data doesn't have %s" % property)
		return null
	return data.get(property)
func _set(property,value):
	if !data.has(property):
		print("data doesn't have %s" % property)
		return null
	data[property] = value
