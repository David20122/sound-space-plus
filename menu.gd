extends Node

func idle_status():
	# after 5 min on the menu switch to "listening to music"
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_details("Main Menu")
	activity.set_state("Listening to music")

	var assets = activity.get_assets()
	assets.set_large_image("icon")

	Discord.activity_manager.update_activity(activity)

func _ready():
	get_tree().paused = false
	$BlackFade.visible = true
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if ProjectSettings.get_setting("application/config/discord_rpc"):
		var activity = Discord.Activity.new()
		activity.set_type(Discord.ActivityType.Playing)
		activity.set_details("Main Menu")
		activity.set_state("Selecting a song")

		var assets = activity.get_assets()
		assets.set_large_image("icon")

		Discord.activity_manager.update_activity(activity)
		
		get_tree().create_timer(300).connect("timeout",self,"idle_status")

var black_fade_target:bool = false
var black_fade:float = 1

func _process(delta):
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.3),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.3),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	$BlackFade.visible = (black_fade != 0)
