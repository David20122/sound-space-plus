extends Node

var leaving:bool = false

var target:String = Rhythia.menu_target

var black_fade_target:bool = false
var black_fade:float = 0

func _ready():
	get_tree().paused = false
	if Rhythia.vr:
		target = "res://vr/vrmenu.tscn"
		Rhythia.vr_player.transform.origin = Vector3(0,0,0)
	PhysicsServer.set_active(true)
	Input.set_custom_mouse_cursor(null)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Rhythia.load_color_txt()
	Rhythia.conmgr_transit = null
	Rhythia.loaded_world = null
	Rhythia.was_replay = Rhythia.replaying
	Rhythia.replaying = false
	if Rhythia.was_replay: Rhythia.restore_prev_state()
	if Rhythia.selected_song: Rhythia.selected_song.discard_notes()
	Rhythia.replay_path = ""
	$BlackFade.visible = true
	black_fade = 1
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var s = Globals.error_sound
	var st = Rhythia.get_stream_with_default("user://loadingmusic",s)
	if st != s:
		$Music.stream = st
		$Music.play()
	
#	$AudioStreamPlayer.play()
	
	var res = RQueue.queue_resource(target)
	if res != OK:
		Rhythia.errorstr = "queue_resource returned %s" % res
		get_tree().change_scene("res://scenes/errors/menuload.tscn")

var result
var left:bool = false

func _process(delta):
#	$AudioStreamPlayer.volume_db = -3 - (40*black_fade)
	$Music.volume_db = -8 - (40*black_fade)
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.3),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.3),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	
	if !leaving:
		if RQueue.is_ready(target):
			result = RQueue.get_resource(target)
			leaving = true
			black_fade_target = true
			if !(result is Object):
				Rhythia.errorstr = "get_resource returned non-object (probably null)"
				get_tree().change_scene("res://scenes/errors/menuload.tscn")
	
	if leaving and result and black_fade == 1:
		get_tree().change_scene_to(result)
