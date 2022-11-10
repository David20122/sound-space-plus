extends Node

func set_rpc_status(state:String):
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_details("Content Manager")
	activity.set_state(state)

	var assets = activity.get_assets()
	assets.set_large_image("icon")

	Discord.activity_manager.update_activity(activity)

func _ready():
	get_tree().paused = false
	$BlackFade.visible = true
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$MenuSong.stream = SSP.get_stream_with_default("user://content",load("res://content/sfx/music/cm.ogg"))
	if $MenuSong.stream is AudioStreamSample: $MenuSong.stream.loop_mode = 1
	else: $MenuSong.stream.loop = true
	
	set_rpc_status("Selecting an action")
	if SSP.play_menu_music:
		$MenuSong.volume_db = -45
		$MenuSong.play()

var black_fade_target:bool = false
var black_fade:float = 1

func _process(delta):
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.3),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.5),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	$BlackFade.visible = black_fade != 0
	
	$MenuSong.volume_db = SSP.music_volume_db - (40*black_fade)
