extends Node

var leaving:bool = false

var target:String = "res://song.tscn"
var target2:String = SSP.selected_space.path

var black_fade_target:bool = false
var black_fade:float = 0

func _ready():
	get_tree().paused = false
	$BlackFade.visible = true
	black_fade = 1
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var s = Globals.error_sound
#	var st = SSP.get_stream_with_default("user://loadingmusic",s)
#	if st != s:
#		$Music.stream = st
#		$Music.play()
	
	$AudioStreamPlayer.play()
	
	var res = RQueue.queue_resource(target)
	var res2 = RQueue.queue_resource(target2)
	if res != OK:
		SSP.errorstr = "song.tscn queue_resource returned %s" % res
		get_tree().change_scene("res://errors/menuload.tscn")
	elif res2 != OK:
		SSP.errorstr = "bg world queue_resource returned %s" % res
		get_tree().change_scene("res://errors/menuload.tscn")
	
	SSP.miss_snd = SSP.get_stream_with_default("user://miss",SSP.miss_snd)
	SSP.hit_snd = SSP.get_stream_with_default("user://hit",SSP.hit_snd)
	SSP.fail_snd = SSP.get_stream_with_default("user://fail",SSP.fail_snd)
	SSP.pb_snd = SSP.get_stream_with_default("user://new_best",SSP.pb_snd)
	SSP.menu_bgm = SSP.get_stream_with_default("user://menu",SSP.menu_bgm)

var result
var result2
var left:bool = false

func _process(delta):
	$AudioStreamPlayer.volume_db = -3 - (40*black_fade)
	$Music.volume_db = -8 - (40*black_fade)
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.75),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.75),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	
	if !leaving:
		if RQueue.is_ready(target) and RQueue.is_ready(target2):
			result = RQueue.get_resource(target)
			result2 = RQueue.get_resource(target2)
			leaving = true
			black_fade_target = true
			SSP.loaded_world = result2
			if !(result is Object):
				SSP.errorstr = "song.tscn get_resource returned non-object (probably null)"
				get_tree().change_scene("res://errors/menuload.tscn")
			if !(result2 is Object):
				SSP.errorstr = "bg world get_resource returned non-object (probably null)"
				get_tree().change_scene("res://errors/menuload.tscn")
	
	if leaving and result and black_fade == 1:
		get_tree().change_scene_to(result)
