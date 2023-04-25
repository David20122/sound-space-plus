class_name GameSettingsCallbacks

var settings:GameSettings

var tree:SceneTreePlus
var window:Window

func bind_to(_settings:GameSettings):
	settings = _settings

	# Approach Rate
	settings.approach.get_setting("rate").changed.connect(approach_rate.bind("rate"))
	settings.approach.get_setting("time").changed.connect(approach_rate.bind("time"))
	settings.approach.get_setting("distance").changed.connect(approach_rate.bind("distance"))

	# Volume
	settings.volume.get_setting("master").changed.connect(volume.bind("Master"))
	settings.volume.get_setting("master_menu").changed.connect(volume.bind("Menu"))
	settings.volume.get_setting("menu_music").changed.connect(volume.bind("Menu Music"))
	settings.volume.get_setting("menu_sfx").changed.connect(volume.bind("Menu SFX"))
	settings.volume.get_setting("master_game").changed.connect(volume.bind("Game"))
	settings.volume.get_setting("game_music").changed.connect(volume.bind("Game Music"))
	settings.volume.get_setting("game_sfx").changed.connect(volume.bind("Game SFX"))

	# FPS
	settings.get_setting("fps_limit").changed.connect(set_fps)

	# Fullscreen
	settings.get_setting("fullscreen").changed.connect(fullscreen)

func approach_rate(_value,value:String):
	var mode = settings.approach.mode
	match mode:
		GameSettings.ApproachMode.DISTANCE_TIME:
			if value == "rate": return
			settings.approach.rate = settings.approach.distance / settings.approach.time
		GameSettings.ApproachMode.DISTANCE_RATE:
			if value == "time": return
			settings.approach.time = settings.approach.distance / settings.approach.rate
		GameSettings.ApproachMode.RATE_TIME:
			if value == "distance": return
			settings.approach.distance = settings.approach.rate * settings.approach.time

var pre_fullscreen_size:Vector2
var pre_fullscreen_mode:int
func fullscreen(value:bool):
	if value and window.mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
		pre_fullscreen_size = window.size
		pre_fullscreen_mode = window.mode
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	elif window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		window.mode = pre_fullscreen_mode
		window.size = pre_fullscreen_size

func volume(value:float,bus:String="Master"):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus),linear_to_db(value))

func set_fps(value:int):
	tree.fps_limit = value
