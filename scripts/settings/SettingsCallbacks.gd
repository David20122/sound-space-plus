class_name GameSettingsCallbacks

var tree:SceneTreePlus
var window:Window

func bind_to(settings:GameSettings):
	settings.volume.get_setting("master").changed.connect(volume.bind("Master"))
	settings.volume.get_setting("master_menu").changed.connect(volume.bind("Menu"))
	settings.volume.get_setting("menu_music").changed.connect(volume.bind("Menu Music"))
	settings.volume.get_setting("menu_sfx").changed.connect(volume.bind("Menu SFX"))
	settings.volume.get_setting("master_game").changed.connect(volume.bind("Game"))
	settings.volume.get_setting("game_music").changed.connect(volume.bind("Game Music"))
	settings.volume.get_setting("game_sfx").changed.connect(volume.bind("Game SFX"))
	settings.get_setting("fullscreen").changed.connect(fullscreen)

var pre_fullscreen_size:Vector2
var pre_fullscreen_mode:int
func fullscreen(value:bool):
	print("Fullscreen: %s" % value)
	if value and window.mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
		pre_fullscreen_size = window.size
		pre_fullscreen_mode = window.mode
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	elif window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		window.mode = pre_fullscreen_mode
		window.size = pre_fullscreen_size

func volume(value:float,bus:String="Master"):
	print("%s: %s" % [bus,value])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus),linear_to_db(value))
