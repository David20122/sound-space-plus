extends Node

func _ready():
	set_process(false)
	get_tree().paused = false
	
	# fix audio pitchshifts
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) > 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"),0)
	
	$BlackFade.visible = true
	$BlackFade.color = Color(0,0,0,black_fade)
	
	yield(get_tree().create_timer(0.5),"timeout")
	
	# for some reason, _ready runs too early on the first load of this scene
	# deferred functions run at the correct time, though.
	self.call_deferred("_begin")
	
#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
#	if ProjectSettings.get_setting("application/config/discord_rpc"):
#		var activity = Discord.Activity.new()
#		activity.set_type(Discord.ActivityType.Playing)
#		activity.set_details("Onboarding")
#		activity.set_state("Changing settings")
#
#		var assets = activity.get_assets()
#		assets.set_large_image("icon")
#
#		Discord.activity_manager.update_activity(activity)

func _begin():
#	active = true
	set_process(true)
	$Controls.set_process(true)
	if SSP.is_init:
		$GameInit.activate()

var black_fade_target:bool = false
var black_fade:float = 1

func _process(delta):
	if Input.is_action_just_pressed("ui_end") and Input.is_key_pressed(KEY_SHIFT):
		get_tree().change_scene("res://menuload.tscn")
	
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.6),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.5),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	$BlackFade.visible = (black_fade != 0)
