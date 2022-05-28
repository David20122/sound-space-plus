extends Node

var leaving:bool = false

var target:String = "res://menu.tscn"

var black_fade_target:bool = false
var black_fade:float = 0

func _ready():
	get_tree().paused = false
	SSP.loaded_world = null
	$BlackFade.visible = true
	black_fade = 1
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var s = Globals.error_sound
	var st = SSP.get_stream_with_default("user://loadingmusic",s)
	if st != s:
		$Music.stream = st
		$Music.play()
	
	$AudioStreamPlayer.play()
	
	var res = RQueue.queue_resource(target)
	if res != OK: get_tree().change_scene("res://menuloaderror.tscn")

var result
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
		if RQueue.is_ready(target):
			result = RQueue.get_resource(target)
			leaving = true
			black_fade_target = true
			if !(result is Object): get_tree().change_scene("res://menuloaderror.tscn")
	
	if leaving and result and black_fade == 1:
		get_tree().change_scene_to(result)
