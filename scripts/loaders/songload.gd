extends Node

var leaving:bool = false

var target:String = "res://scenes/song.tscn"
var target2:String = Rhythia.selected_space.path

var black_fade_target:bool = false
var black_fade:float = 0


func _ready():
	print("song loading")
	get_tree().paused = false
	if Rhythia.vr:
		Rhythia.vr_player.transform.origin = Vector3(0,-2.5,4.5)
	$BlackFade.visible = true
	black_fade = 1
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var s = Globals.error_sound
#	var st = Rhythia.get_stream_with_default("user://loadingmusic",s)
#	if st != s:
#		$Music.stream = st
#		$Music.play()
	
#	$AudioStreamPlayer.play()
	
	var res = RQueue.queue_resource(target)
	var res2 = RQueue.queue_resource(target2)
	if res != OK:
		Rhythia.errorstr = "song.tscn queue_resource returned %s" % res
		get_tree().change_scene("res://scenes/errors/songload.tscn")
	elif res2 != OK:
		Rhythia.errorstr = "bg world queue_resource returned %s" % res
		get_tree().change_scene("res://scenes/errors/songload.tscn")
	
	Rhythia.miss_snd = Rhythia.get_stream_with_default("user://miss",Rhythia.def_miss_snd)
	Rhythia.hit_snd = Rhythia.get_stream_with_default("user://hit",Rhythia.def_hit_snd)
	Rhythia.fail_snd = Rhythia.get_stream_with_default("user://fail",Rhythia.def_fail_snd)
	Rhythia.pb_snd = Rhythia.get_stream_with_default("user://new_best",Rhythia.def_pb_snd)
	Rhythia.menu_bgm = Rhythia.get_stream_with_default("user://menu",Rhythia.def_menu_bgm)
	Rhythia.was_replay = false

var result
var result2
var left:bool = false

var finishing = false
func warning_menu_exit():
	Globals.confirm_prompt.s_back.play()
	yield(Globals.confirm_prompt,"done_closing")
	get_tree().change_scene("res://scenes/loaders/menuload.tscn")

func progress(v):
	$P.visible = true
	$P.value = v*100

func finish():
	if finishing: return
	finishing = true
	result = RQueue.get_resource(target)
	result2 = RQueue.get_resource(target2)
	Rhythia.loaded_world = result2
	if !(result is Object):
		Rhythia.errorstr = "song.tscn get_resource returned non-object (probably null)"
		get_tree().change_scene("res://scenes/errors/songload.tscn")
	if !(result2 is Object):
		Rhythia.errorstr = "bg world get_resource returned non-object (probably null)"
		get_tree().change_scene("res://scenes/errors/songload.tscn")
	
	Rhythia.load_color_txt()
	
	if Input.is_key_pressed(KEY_L):
		Rhythia.replaying = true
		Rhythia.replay = Replay.new()
	
	if Rhythia.replaying:
		Rhythia.save_current_state()
		Rhythia.replay.connect("progress",self,"progress")
		Rhythia.replay.read_data(Rhythia.replay_path)
		yield(Rhythia.replay,"done_loading")
	
	black_fade_target = true
	yield(get_tree().create_timer(0.5),"timeout")

	
	# Warnings that can't be disabled (since they're always a problem)
	if Rhythia.selected_song.read_notes().size() == 0:
		Globals.confirm_prompt.open(
			"This map doesn't have any notes.",
			"Warning",
			[{text="Return to menu"}]
		)
		var option = yield(Globals.confirm_prompt,"option_selected")
		Globals.confirm_prompt.close()
		warning_menu_exit()
		return
	
	if Rhythia.selected_song.stream() == Globals.error_sound:
		Globals.confirm_prompt.open(
			"This map's audio appears to be broken. You can still play the map, but there won't be any music.",
			"Warning",
			[{text="Return to menu"},{text="Continue"}]
		)
		var option = yield(Globals.confirm_prompt,"option_selected")
		Globals.confirm_prompt.close()
		if option == 0:
			warning_menu_exit()
			return
		else:
			Globals.confirm_prompt.s_next.play()
			yield(Globals.confirm_prompt,"done_closing")
	
	# Warnings that can be disabled (since they're mostly performance or gameplay related)
	if Rhythia.show_warnings:
		if (
			(
				Rhythia.smart_trail and 
				(Rhythia.trail_detail > 100 or 
				(Rhythia.trail_detail * Rhythia.trail_time) > 10)
			) or (Rhythia.trail_detail >= 350)
		):
			var warn_txt = "Your trail detail is set very high. This can cause significant performance issues and possibly crashes."
			if Rhythia.smart_trail:
				warn_txt = "Your trail detail/time is set very high. This can cause significant performance issues and possibly crashes."
			Globals.confirm_prompt.open(
				warn_txt,
				"Warning",
				[{text="Return to menu"},{text="Continue"}]
			)
			var option = yield(Globals.confirm_prompt,"option_selected")
			Globals.confirm_prompt.close()
			if option == 0:
				warning_menu_exit()
				return
			else:
				Globals.confirm_prompt.s_next.play()
				yield(Globals.confirm_prompt,"done_closing")
		
		if Rhythia.get("approach_rate") <= 0:
			Globals.confirm_prompt.open(
				"You are using a non-standard approach rate. Some things might not work correctly.",
				"Warning",
				[{text="Return to menu"},{text="Continue"}]
			)
			var option = yield(Globals.confirm_prompt,"option_selected")
			Globals.confirm_prompt.close()
			if option == 0:
				warning_menu_exit()
				return
			else:
				Globals.confirm_prompt.s_next.play()
				yield(Globals.confirm_prompt,"done_closing")
		
		if Rhythia.hitwindow_ms <= 18:
			Globals.confirm_prompt.open(
				"Your hitwindow is set very low. This may lead to some notes being impossible to hit.",
				"Warning",
				[{text="Return to menu"},{text="Continue"}]
			)
			var option = yield(Globals.confirm_prompt,"option_selected")
			Globals.confirm_prompt.close()
			if option == 0:
				warning_menu_exit()
				return
			else:
				Globals.confirm_prompt.s_next.play()
				yield(Globals.confirm_prompt,"done_closing")
	
	leaving = true

func _process(delta):
#	$AudioStreamPlayer.volume_db = -3 - (50*black_fade)
	$Music.volume_db = -8 - (50*black_fade)
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.6),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.3),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	
	if !leaving and !finishing:
		if RQueue.is_ready(target) and RQueue.is_ready(target2):
			finish()
	
	if leaving and result and black_fade == 1:
		get_tree().change_scene_to(result)
