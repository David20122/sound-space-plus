extends Node

var leaving:bool = false

var target:String = "res://song.tscn"
var target2:String = SSP.selected_space.path

var black_fade_target:bool = false
var black_fade:float = 0


func _ready():
	print("song loading")
	get_tree().paused = false
	if SSP.vr:
		SSP.vr_player.transform.origin = Vector3(0,-2.5,4.5)
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
		get_tree().change_scene("res://errors/songload.tscn")
	elif res2 != OK:
		SSP.errorstr = "bg world queue_resource returned %s" % res
		get_tree().change_scene("res://errors/songload.tscn")
	
	SSP.miss_snd = SSP.get_stream_with_default("user://miss",SSP.def_miss_snd)
	SSP.hit_snd = SSP.get_stream_with_default("user://hit",SSP.def_hit_snd)
	SSP.fail_snd = SSP.get_stream_with_default("user://fail",SSP.def_fail_snd)
	SSP.pb_snd = SSP.get_stream_with_default("user://new_best",SSP.def_pb_snd)
	SSP.menu_bgm = SSP.get_stream_with_default("user://menu",SSP.def_menu_bgm)
	SSP.was_replay = false

var result
var result2
var left:bool = false

var finishing = false
func warning_menu_exit():
	Globals.confirm_prompt.s_back.play()
	yield(Globals.confirm_prompt,"done_closing")
	get_tree().change_scene("res://menuload.tscn")

func progress(v):
	$P.visible = true
	$P.value = v*100

func finish():
	if finishing: return
	finishing = true
	result = RQueue.get_resource(target)
	result2 = RQueue.get_resource(target2)
	SSP.loaded_world = result2
	if !(result is Object):
		SSP.errorstr = "song.tscn get_resource returned non-object (probably null)"
		get_tree().change_scene("res://errors/songload.tscn")
	if !(result2 is Object):
		SSP.errorstr = "bg world get_resource returned non-object (probably null)"
		get_tree().change_scene("res://errors/songload.tscn")
	
	SSP.load_color_txt()
	
	if Input.is_key_pressed(KEY_L):
		SSP.replaying = true
		SSP.replay = Replay.new()
	
	if SSP.replaying:
		SSP.save_current_state()
		SSP.replay.connect("progress",self,"progress")
		SSP.replay.read_data(SSP.replay_path)
		yield(SSP.replay,"done_loading")
	
	black_fade_target = true
	yield(get_tree().create_timer(0.5),"timeout")

	
	# Warnings that can't be disabled (since they're always a problem)
	if SSP.selected_song.read_notes().size() == 0:
		Globals.confirm_prompt.open(
			"This map doesn't have any notes.",
			"Warning",
			[{text="Return to menu"}]
		)
		var option = yield(Globals.confirm_prompt,"option_selected")
		Globals.confirm_prompt.close()
		warning_menu_exit()
		return
	
	if SSP.selected_song.stream() == Globals.error_sound:
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
	if SSP.show_warnings:
		if (
			(
				SSP.smart_trail and 
				(SSP.trail_detail > 100 or 
				(SSP.trail_detail * SSP.trail_time) > 10)
			) or (SSP.trail_detail >= 350)
		):
			var warn_txt = "Your trail detail is set very high. This can cause significant performance issues and possibly crashes."
			if SSP.smart_trail:
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
		
		if SSP.approach_rate <= 0:
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
		
		if SSP.hitwindow_ms <= 18:
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
	$AudioStreamPlayer.volume_db = -3 - (50*black_fade)
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
