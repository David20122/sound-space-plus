extends Node

# Signals
signal mods_changed
signal speed_mod_changed
signal selected_song_changed
signal selected_space_changed
signal selected_colorset_changed
signal selected_mesh_changed
signal selected_hit_effect_changed
signal selected_miss_effect_changed
signal init_stage_reached
signal map_list_ready
signal volume_changed
signal favorite_songs_changed
signal menu_music_state_changed
signal download_start
signal download_done


# Directories
var user_pack_dir:String = Globals.p("user://packs")
var user_mod_dir:String = Globals.p("user://mods")
var user_vmap_dir:String = Globals.p("user://vmaps")
var user_map_dir:String = Globals.p("user://maps")
var user_best_dir:String = Globals.p("user://bests")
var user_colorset_dir:String = Globals.p("user://colorsets")

# Installed content info
var installed_dlc:Array = ["ssp_basegame"]
var installed_mods:Array = []
var installed_packs:Array = []


# Registries
var registry_colorset:Registry
var registry_song:Registry
var registry_world:Registry
var registry_mesh:Registry
var registry_effect:Registry
# Selected items
var selected_space:BackgroundWorld
var selected_colorset:ColorSet
var selected_song:Song
var selected_mesh:NoteMesh
var selected_hit_effect:NoteEffect
var selected_miss_effect:NoteEffect
# Selectors
func select_colorset(set:ColorSet):
	if set:
		selected_colorset = set
		emit_signal("selected_colorset_changed",set)
func select_world(world:BackgroundWorld):
	if world:
		selected_space = world
		emit_signal("selected_space_changed",world)
func select_mesh(mesh:NoteMesh):
	selected_mesh = mesh
	emit_signal("selected_mesh_changed",mesh)
func select_hit_effect(effect:NoteEffect):
	if effect:
		selected_hit_effect = effect
		emit_signal("selected_hit_effect_changed",effect)
func select_miss_effect(effect:NoteEffect):
	if effect:
		selected_miss_effect = effect
		emit_signal("selected_miss_effect_changed",effect)
func select_song(song:Song):
	if song.is_online:
		emit_signal("download_start")
		get_tree().paused = true
		
		print("[Online Map] Starting download")
		var id:String = Online.download_map(song)
		
		print("[Online Map] Waiting for download to finish")
		var result:Dictionary = yield(Online,"map_downloaded")
		while result.id != id:
			print("[Online Map] Wrong download: %s != %s" % [result.id, id])
			result = yield(Online,"map_downloaded")
		print("[Online Map] Download finished")
		
		get_tree().paused = false
		if result.success:
			emit_signal("download_done")
			selected_song = song
			emit_signal("selected_song_changed",song)
		elif result.error == "010-100":
			emit_signal("download_done")
		else:
			Globals.confirm_prompt.s_alert.play()
			Globals.confirm_prompt.open(
				"Failed to download map.\nError code: %s" % result.error,
				"Error",
				[{text="OK"}]
			)
			yield(Globals.confirm_prompt,"option_selected")
			Globals.confirm_prompt.s_back.play()
			Globals.confirm_prompt.close()
			yield(Globals.confirm_prompt,"done_closing")
			emit_signal("download_done")
	else:
		selected_song = song
		emit_signal("selected_song_changed",song)


# Song ending state data
var just_ended_song:bool = false
var song_end_type:int = Globals.END_FAIL
var song_end_misses:int
var song_end_hits:int
var song_end_total_notes:int
var song_end_position:float
var song_end_pause_count:int
var song_end_accuracy_str:String
var song_end_time_str:String
var song_end_length:float

# Replay data
var replay:Replay
var replay_path:String = ""
var was_replay:bool = false
var replaying:bool = false

# State/transit data
var rainbow_t:float = 0 # Keep rainbow effects in perfect sync
var alert:String = "" # Used for startup
var should_ask_about_replays:bool = true # Replay setting was not found, ask
var do_archive_convert:bool = false # Has "Convert SS Archive" been pressed?
var conmgr_transit = null # Content manager transit data, can vary widely
var errornum:int = 0 # Used by settings file errors
var errorstr:String = "" # Used by loading errors (ie. errors/songload and errors/menuload)
var first_init_done = false # Don't reload mods as that can cause problems
var loaded_world = null # Holds the bg world for transit between songload and song player
var menu_target:String = ProjectSettings.get_setting("application/config/default_menu_target")

# Song list position/search persistence
var was_auto_play_switch:bool = true
var last_search_str:String = ""
var last_search_incl_broken:bool = false
var last_search_flip_sort:bool = false
var last_search_flip_name_sort:bool = false
var last_page_num:int = 0
var last_difficulty_filter:Array = [
	Globals.DIFF_EASY,
	Globals.DIFF_MEDIUM,
	Globals.DIFF_HARD,
	Globals.DIFF_LOGIC,
	Globals.DIFF_AMOGUS,
	Globals.DIFF_UNKNOWN
]

# VR
var vr:bool = false
var fake_vr:bool = false
var vr_available:bool = false
var vr_interface:ARVRInterface
var vr_player:VRPlayer
var vr_left_handed:bool = false
var vr_controller_type:int = Globals.VR_GENERIC

# Song queue
var queue_active:bool = false
var queue_pos:int = 0
var song_queue:Array = []
var just_ended_queue:bool = false
var queue_end_type:int = Globals.END_FAIL
var queue_end_misses:int
var queue_end_hits:int
var queue_end_total_notes:int
var queue_end_position:float
var queue_end_pause_count:int
var queue_end_accuracy_str:String
var queue_end_time_str:String
var queue_end_length:float




# Loaded sounds
var miss_snd:AudioStream
var hit_snd:AudioStream
var fail_snd:AudioStream
var pb_snd:AudioStream
var menu_bgm:AudioStream
# Default sounds - allows for removing custom sounds w/o restarting the game
var normal_pb_sound
var def_miss_snd:AudioStream
var def_hit_snd:AudioStream
var def_fail_snd:AudioStream
var def_pb_snd:AudioStream
var def_menu_bgm:AudioStream

# Keep fail sounds playing on scene switch
var fail_asp:AudioStreamPlayer = AudioStreamPlayer.new()


# VR startup
func start_vr():
	if vr:
		print("VR already active")
		return
	print("VR START")
	vr = true
	
	get_viewport().hdr = false
	OS.vsync_enabled = false
	Engine.target_fps = 90
	
	if Input.is_key_pressed(KEY_SHIFT):
		print("enabling fake vr")
		OS.window_maximized = true
		fake_vr = true
		
		var ev = InputEventKey.new()
		ev.scancode = KEY_F
		InputMap.action_add_event("vr_switch_hands",ev)
		
		ev = InputEventMouseButton.new()
		ev.button_index = BUTTON_LEFT
		InputMap.action_add_event("vr_click",ev)
	else:
		vr_interface.initialize()
		get_viewport().arvr = true
		
		# Hand switch binds
		var ev = InputEventJoypadButton.new()
		ev.button_index = JOY_OCULUS_MENU
		InputMap.action_add_event("vr_switch_hands",ev)
		
		ev = InputEventJoypadButton.new()
		ev.button_index = JOY_OPENVR_MENU
		InputMap.action_add_event("vr_switch_hands",ev)
		
		# Give up binds
		ev = InputEventJoypadButton.new()
		ev.button_index = JOY_VR_GRIP
		InputMap.action_add_event("give_up",ev)
		
		ev = InputEventJoypadMotion.new()
		ev.axis = JOY_VR_ANALOG_GRIP
		InputMap.action_add_event("give_up",ev)
		
		# Pause binds
		ev = InputEventJoypadButton.new()
		ev.button_index = JOY_VR_TRIGGER
		InputMap.action_add_event("pause",ev)
		
		ev = InputEventJoypadButton.new()
		ev.button_index = JOY_OCULUS_BY
		InputMap.action_add_event("pause",ev)
		
		ev = InputEventJoypadMotion.new()
		ev.axis = JOY_VR_ANALOG_TRIGGER
		InputMap.action_add_event("pause",ev)
		
		# Click binds
		ev = InputEventJoypadButton.new()
		ev.button_index = JOY_VR_TRIGGER
		InputMap.action_add_event("vr_click",ev)
		
		ev = InputEventJoypadButton.new()
		ev.button_index = JOY_OCULUS_AX
		InputMap.action_add_event("vr_click",ev)
		
		ev = InputEventJoypadMotion.new()
		ev.axis = JOY_VR_ANALOG_TRIGGER
		InputMap.action_add_event("vr_click",ev)
	
	var vr_av:VRPlayer = load("res://vr/VRPlayer.tscn").instance()
	get_tree().root.add_child(vr_av)
	vr_av.name = "VRPlayer"
	vr_player = vr_av
	
	menu_target = "res://vr/vrmenu.tscn"
	get_tree().change_scene("res://menuload.tscn")

# Song queue
func prepare_queue():
	record_replays = false
	queue_active = true
	just_ended_queue = false
	queue_pos = 0
	
	queue_end_type = Globals.END_FAIL
	queue_end_misses = 0
	queue_end_hits = 0
	queue_end_total_notes = 0
	queue_end_position = 0
	queue_end_pause_count = 0
	queue_end_length = 0
	for s in song_queue:
		queue_end_length += s.last_ms

func get_next():
	queue_pos += 1
	print(queue_pos)
	
	queue_end_type = song_end_type
	queue_end_misses += song_end_misses
	queue_end_hits += song_end_hits
	queue_end_total_notes += song_end_total_notes
	queue_end_position += clamp(song_end_position,0,selected_song.last_ms)
	queue_end_pause_count += song_end_pause_count
	
	if song_end_type == Globals.END_GIVEUP or queue_pos == song_queue.size():
		print("all done!")
		just_ended_queue = true
		queue_active = false
		return null
	
	return song_queue[queue_pos]

# Engine node functions + debug command line
func _ready():
	fail_asp.volume_db = -10
	call_deferred("add_child",fail_asp)
	pause_mode = PAUSE_MODE_PROCESS
	Globals.connect("console_sent",self,"_console")
func _process(delta):
	# Rainbow sync
	rainbow_t = fmod(rainbow_t + (delta*0.5),10)
	# Global hotkeys
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

# Debug
var desync_alerts:bool = false
func _console(cmd:String,args:String):
	match cmd:
		"queue":
			var ids = args.split(" ",false)
			if ids.size() == 0:
				if song_queue.size() == 0:
					console_cmd_error("Must specify at least 1 map id")
					return
				else:
					Globals.notify(Globals.NOTIFY_SUCCEED,"reactivated queue")
					prepare_queue()
					return
			else:
				var maps = []
				for id in ids:
					var song = registry_song.get_item(id)
					if song: maps.append(song)
					else: Globals.notify(Globals.NOTIFY_ERROR,"No song found with id %s" % [id],"Error")
				if maps.size() == 0:
					console_cmd_error("No valid maps specified")
					return
				select_song(maps[0])
				song_queue = maps
				prepare_queue()
				Globals.notify(Globals.NOTIFY_SUCCEED,"queue OK")
		"play":
			get_tree().change_scene("res://songload.tscn")
		"desyncalerts":
			Globals.notify(Globals.NOTIFY_SUCCEED,"Enabled desync alerts","Success")
			desync_alerts = true

# Utility functions
func console_cmd_error(body:String):
	Globals.confirm_prompt.s_alert.play()
	Globals.confirm_prompt.open(body,"Error",[{text="OK"}])
	yield(Globals.confirm_prompt,"option_selected")
	Globals.confirm_prompt.s_back.play()
	Globals.confirm_prompt.close()
func update_rpc_song(): # Discord RPC
	if !ProjectSettings.get_setting("application/config/discord_rpc") or selected_song == null: return
	var txt = ""
	var mods = []
	if mod_nofail: mods.append("Nofail")
	if mod_speed_level != Globals.SPEED_NORMAL:
		match mod_speed_level:
			Globals.SPEED_MMM: mods.append("Speed---")
			Globals.SPEED_MM: mods.append("Speed--")
			Globals.SPEED_M: mods.append("Speed-")
			Globals.SPEED_P: mods.append("Speed+")
			Globals.SPEED_PP: mods.append("Speed++")
			Globals.SPEED_PPP: mods.append("Speed+++")
			Globals.SPEED_PPPP: mods.append("Speed++++")
			Globals.SPEED_CUSTOM: mods.append("Speed %s%%" % [Globals.speed_multi[Globals.SPEED_CUSTOM] * 100])
	if mod_sudden_death: mods.append("SuddenDeath")
	if mod_extra_energy: mods.append("Energy+")
	if mod_no_regen: mods.append("NoRegen")
	if mod_mirror_x or mod_mirror_y:
		var mirrorst = "Mirror"
		if SSP.mod_mirror_x: mirrorst += "X"
		if SSP.mod_mirror_y: mirrorst += "Y"
		mods.append(mirrorst)
	if mod_ghost: mods.append("Ghost")
	if mod_nearsighted: mods.append("Nearsight")
	
	if mods.size() == 0: txt = "No modifiers"
	else:
		for i in range(mods.size()):
			if i != 0: txt += ", "
			txt += mods[i]
	
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state(txt)
	activity.set_details(selected_song.name)

	var assets = activity.get_assets()
	assets.set_large_image("icon")

	Discord.activity_manager.update_activity(activity)
func get_stream_with_default(path:String,default:AudioStream) -> AudioStream:
	path = Globals.p(path)
	var file:File = File.new()
	if file.file_exists(path + ".ogg"): path += ".ogg"
	elif file.file_exists(path + ".mp3"): path += ".mp3"
	elif file.file_exists(path + ".wav"): path += ".wav"
	if file.file_exists(path):
		if !path.begins_with("res://"):
			var stream = Globals.audioLoader.load_file(path)
			if stream and stream is AudioStream: return stream
		else: 
			var mf:AudioStream = load(path) as AudioStream
			if mf is AudioStream:
				if mf is AudioStreamOGGVorbis or mf is AudioStreamMP3: mf.loop = false
				elif mf is AudioStreamSample: mf.loop_mode = AudioStreamSample.LOOP_DISABLED
				return mf
	return default




# Modifiers - Normal
var mod_extra_energy:bool = false setget set_mod_extra_energy # Easy Mode
var mod_no_regen:bool = false setget set_mod_no_regen # Hard Mode
var mod_speed_level:int = Globals.SPEED_NORMAL setget set_mod_speed_level
var mod_nofail:bool = false setget set_mod_nofail
var mod_mirror_x:bool = false setget set_mod_mirror_x
var mod_mirror_y:bool = false setget set_mod_mirror_y
var mod_nearsighted:bool = false setget set_mod_nearsighted
var mod_ghost:bool = false setget set_mod_ghost
var mod_sudden_death:bool = false setget set_mod_sudden_death
var mod_chaos:bool = false setget set_mod_chaos
# Modifiers - Custom values
var start_offset:float = 0 setget _set_start_offset
var note_hitbox_size:float = 1.140 setget _set_hitbox_size
var hitwindow_ms:float = 55 setget _set_hitwindow
var custom_speed:float = 1 setget _set_custom_speed
# Modifiers - Special
var health_model:int = Globals.HP_SOUNDSPACE setget _set_health_model
var grade_system:int = Globals.GRADE_SSP setget _set_grade_system
var visual_mode:bool = false setget set_visual_mode

# Mod setters - Normal
func set_mod_extra_energy(v:bool):
	if v:
		mod_sudden_death = false
		mod_nofail = false
	mod_extra_energy = v; emit_signal("mods_changed")
func set_mod_no_regen(v:bool):
	if v:
		mod_sudden_death = false
		mod_nofail = false
	mod_no_regen = v; emit_signal("mods_changed")
func set_mod_speed_level(v:int):
	mod_speed_level = v; emit_signal("mods_changed"); emit_signal("speed_mod_changed")
func set_mod_nofail(v:bool):
	if v:
		mod_extra_energy = false
		mod_no_regen = false
		mod_sudden_death = false
	else:
		visual_mode = false
	mod_nofail = v; emit_signal("mods_changed")
func set_mod_mirror_x(v:bool):
	mod_mirror_x = v; emit_signal("mods_changed")
func set_mod_mirror_y(v:bool):
	mod_mirror_y = v; emit_signal("mods_changed")
func set_mod_nearsighted(v:bool):
	mod_nearsighted = v; emit_signal("mods_changed")
func set_mod_ghost(v:bool):
	mod_ghost = v; emit_signal("mods_changed")
func set_mod_sudden_death(v:bool):
	if v:
		mod_extra_energy = false
		mod_no_regen = false
		mod_nofail = false
	mod_sudden_death = v; emit_signal("mods_changed")
func set_mod_chaos(v:bool):
	mod_chaos = v; emit_signal("mods_changed")
# Mod setters - Custom values
func _set_start_offset(v:float):
	start_offset = v; emit_signal("mods_changed")
func _set_hitbox_size(v:float):
	note_hitbox_size = v; emit_signal("mods_changed")
func _set_hitwindow(v:float):
	hitwindow_ms = v; emit_signal("mods_changed")
func _set_custom_speed(v:float):
	print("custom speed changed")
	custom_speed = v
	Globals.speed_multi[Globals.SPEED_CUSTOM] = v
	emit_signal("mods_changed")
	emit_signal("speed_mod_changed")
# Mod setters - Special
func set_visual_mode(v:bool):
	if v:
		set_mod_nofail(true)
	visual_mode = v; emit_signal("mods_changed")
func _set_health_model(v:int):
	health_model = v; emit_signal("mods_changed")
func _set_grade_system(v:int):
	grade_system = v; emit_signal("mods_changed")




# Settings - Notes
var approach_rate:float = 40
var spawn_distance:float = 40
var note_spawn_effect:bool = false
var fade_length:float = 0.5

var show_hit_effect:bool = true
var hit_effect_at_cursor:bool = true

var show_miss_effect:bool = true

# Settings - Camera/Controls
var sensitivity:float = 0.5
var parallax:float = 6.5 # Camera
var ui_parallax:float = 1.63
var grid_parallax:float = 0
var camera_mode:int = Globals.CAMERA_HALF_LOCK
var cam_unlock:bool = false
var lock_mouse:bool = true
var edge_drift:float = 0

# Settings - Replays
var record_replays:bool = false
var alt_cam:bool = true

# Settings - Cursor
var rainbow_cursor:bool = false
var cursor_trail:bool = false
var smart_trail:bool = false
var trail_detail:int = 10
var trail_time:float = 0.15
var cursor_scale:float = 1
var enable_drift_cursor:bool = true
var cursor_spin:float = 0
var cursor_face_velocity:bool = false # Disabled

# Settings - HUD
var display_true_combo:bool = true
var show_config:bool = true
var enable_grid:bool = false
var enable_border:bool = true
var show_hp_bar:bool = true
var show_timer:bool = true
var show_left_panel:bool = true
var show_right_panel:bool = true
var show_cursor:bool = true
var show_accuracy_bar:bool = true
var show_letter_grade:bool = true
var attach_hp_to_grid:bool = false
var attach_timer_to_grid:bool = false
var simple_hud:bool = false
var faraway_hud:bool = false
var rainbow_grid:bool = false
var rainbow_hud:bool = false
var friend_position:int = Globals.FRIEND_BEHIND_GRID # Hidden
var note_visual_approach:bool = false # Experimental

# Settings - Audio
var auto_preview_song:bool = true
var play_hit_snd:bool = true
var play_miss_snd:bool = true
var music_offset:float = 0
var play_menu_music:bool = false setget _set_menu_music
var music_volume_db:float = 0 setget _set_music_volume
func _set_menu_music(v:bool):
	play_menu_music = v; emit_signal("menu_music_state_changed")
func _set_music_volume(v:float):
	music_volume_db = v; emit_signal("volume_changed")

# Settings - Misc
var show_warnings:bool = true
var auto_maximize:bool = true

# Settings - Experimental



# Favorited songs
var favorite_songs:Array = []
func save_favorites():
	var file:File = File.new()
	file.open(Globals.p("user://favorites.txt"),File.WRITE)
	var txt:String = ""
	for s in favorite_songs:
		if s != favorite_songs[0]: txt += "\n"
		txt += s
	file.store_line(txt)
	file.close()
func is_favorite(id:String):
	return favorite_songs.has(id)
func add_favorite(id:String):
	if !favorite_songs.has(id):
		favorite_songs.append(id)
		emit_signal("favorite_songs_changed")
		save_favorites()
func remove_favorite(id:String):
	if favorite_songs.has(id):
		favorite_songs.remove(favorite_songs.find(id))
		emit_signal("favorite_songs_changed")
		save_favorites()



# Personal bests
func do_pb_check_and_set() -> bool:
	if mod_nofail or was_replay or start_offset != 0 or just_ended_queue: return false
	var has_passed:bool = song_end_type == Globals.END_PASS
	var pb:Dictionary = {}
	pb.position = song_end_position
	pb.length = song_end_length
	pb.hit_notes = song_end_hits
	pb.total_notes = song_end_total_notes
	pb.pauses = song_end_pause_count
	pb.has_passed = song_end_type == Globals.END_PASS
	return selected_song.set_pb_if_better(generate_pb_str(true),pb)
func get_best():
	return selected_song.get_pb(generate_pb_str(true))

func generate_pb_str(for_pb:bool=false):
	var pts:Array = []
	match mod_speed_level:
		Globals.SPEED_MMM: pts.append("s:---")
		Globals.SPEED_MM: pts.append("s:--")
		Globals.SPEED_M: pts.append("s:-")
		Globals.SPEED_NORMAL: pts.append("s:=")
		Globals.SPEED_P: pts.append("s:+")
		Globals.SPEED_PP: pts.append("s:++")
		Globals.SPEED_PPP: pts.append("s:+++")
		Globals.SPEED_PPPP: pts.append("s:++++")
		Globals.SPEED_CUSTOM: pts.append("s:c%.2f" % custom_speed)
	match health_model:
		Globals.HP_OLD: pts.append("hp_old")
		Globals.HP_SOUNDSPACE: pass # prevents wiping of old pbs
	pts.append("hitw:%s" % String(floor(hitwindow_ms)))
	var hb = note_hitbox_size
	pts.append("hbox:%.02f" % note_hitbox_size)
	pts.append("ar:%d" % sign(approach_rate))
	if !for_pb and start_offset != 0: pts.append("so:%f" % start_offset)
	if music_volume_db <= -50: pts.append("silent")
	
	if mod_sudden_death: pts.append("m_sd")
	if mod_extra_energy: pts.append("m_morehp")
	if mod_no_regen: pts.append("m_noregen")
	if mod_mirror_x: pts.append("m_mirror_x")
	if mod_mirror_y: pts.append("m_mirror_y")
	if mod_nearsighted: pts.append("m_nsight")
	if mod_ghost: pts.append("m_ghost")
	if mod_sudden_death: pts.append("m_sd")
	if mod_chaos: pts.append("m_chaos")
	if mod_nofail: pts.append("m_nofail") # for replays
	
	pts.sort()
	
	var s:String = ""
	for i in range(pts.size()):
		if i != 0: s += ";"
		s += pts[i]
	
	return s

# PB string state data (for replays)
func parse_pb_str(txt:String):
	var data:Dictionary = {}
	var pts:Array = txt.split(";",false)
	data.health_model = Globals.HP_SOUNDSPACE
	
	data.start_offset = 0
	data.mod_sudden_death = false
	data.mod_extra_energy = false
	data.mod_no_regen = false
	data.mod_mirror_x = false
	data.mod_mirror_y = false
	data.mod_nearsighted = false
	data.mod_ghost = false
	data.mod_chaos = false
	data.mod_nofail = false
	
	for s in pts:
		if s.begins_with("s:c"):
			data.mod_speed_level = Globals.SPEED_CUSTOM
			data.custom_speed = float(s.substr(3))
		elif s.begins_with("hitw:"):
			data.hitwindow_ms = float(s.substr(5))
		elif s.begins_with("so:"):
			data.start_offset = float(s.substr(3))
		elif s.begins_with("hbox:"):
			data.note_hitbox_size = float(s.substr(5))
		else:
			match s:
				"s:---": data.mod_speed_level = Globals.SPEED_MMM
				"s:--": data.mod_speed_level = Globals.SPEED_MM
				"s:-": data.mod_speed_level = Globals.SPEED_M
				"s:=": data.mod_speed_level = Globals.SPEED_NORMAL
				"s:+": data.mod_speed_level = Globals.SPEED_P
				"s:++": data.mod_speed_level = Globals.SPEED_PP
				"s:+++": data.mod_speed_level = Globals.SPEED_PPP
				"s:++++": data.mod_speed_level = Globals.SPEED_PPPP
				"hp_old": data.health_model = Globals.HP_OLD
				"m_sd": data.mod_sudden_death = true
				"m_morehp": data.mod_extra_energy = true
				"m_noregen": data.mod_no_regen = true
				"m_mirror_x": data.mod_mirror_x = true
				"m_mirror_y": data.mod_mirror_y = true
				"m_nsight": data.mod_nearsighted = true
				"m_ghost": data.mod_ghost = true
				"m_chaos": data.mod_chaos = true
				"m_nofail": data.mod_nofail = true
	return data
var prev_state:Dictionary = {}
func save_current_state(): prev_state = parse_pb_str(generate_pb_str())
func restore_prev_state(): for k in prev_state.keys(): set(k,prev_state.get(k))
func apply_state(state:Dictionary): for k in state.keys(): set(k,state.get(k))

# Legacy PB conversion
var personal_bests:Dictionary = {}
func convert_song_pbs(song:Song):
	for pb in personal_bests.get(song.id,[]):
		mod_extra_energy = pb.mod_extra_energy
		mod_no_regen = pb.mod_no_regen
		mod_speed_level = pb.mod_speed_level
		var npb = {
			"position": pb.position,
			"length": pb.length,
			"hit_notes": pb.hit_notes,
			"total_notes": pb.total_notes,
			"pauses": pb.pauses,
			"has_passed": pb.has_passed
		}
		song.set_pb_if_better(generate_pb_str(true),npb)
func load_pbs():
	var file:File = File.new()
	if file.file_exists(Globals.p("user://pb.json")):
		file.open(Globals.p("user://pb.json"),File.READ)
		personal_bests = parse_json(file.get_as_text())
		file.close()
	elif file.file_exists(Globals.p("user://pb")):
		file.open(Globals.p("user://pb"),File.READ)
		var ver:int = file.get_16() # READ 2
		var x:int = file.get_16() # READ 2
		while !file.eof_reached():
			if x == 16384 or file.eof_reached():
				file.close()
				return
			var songid:String
			if ver == 2: songid = file.get_pascal_string()
			else: songid = file.get_line() # READ STRING+1
			personal_bests[songid] = []
			x = file.get_16() # READ 2
			while x == 69:
				var pb = {}
				pb.has_passed = bool(file.get_8()) # READ 1
				pb.mod_extra_energy = bool(file.get_8()) # READ 1
				pb.mod_no_regen = bool(file.get_8()) # READ 1
				pb.mod_speed_level = file.get_8() # READ 1
				pb.position = file.get_64() # READ 8
				pb.length = file.get_64() # READ 8
				pb.hit_notes = file.get_32() # READ 4
				pb.total_notes = file.get_32() # READ 4
				pb.pauses = file.get_16() # READ 2
				personal_bests[songid].append(pb)
				x = file.get_16() # READ 2
		file.close()




# Settings file
const current_sf_version = 42 # SV
func load_saved_settings():
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_L): 
		print("force settings read error")
		return -1
	var file:File = File.new()
	if file.file_exists(Globals.p("user://settings")):
		var err = file.open(Globals.p("user://settings"),File.READ)
		if err != OK:
			print("file.open failed"); return 1
		var sv:int = file.get_16()
		if sv <= 3 or sv > current_sf_version:
			print("invalid file version"); return 2
		approach_rate = file.get_float()
		sensitivity = file.get_float()
		play_hit_snd = bool(file.get_8())
		play_miss_snd = bool(file.get_8())
		if sv >= 4: auto_preview_song = bool(file.get_8())
		if file.get_8() != 0:
			print("integ 1"); return 3
		OS.vsync_enabled = bool(file.get_8())
		OS.vsync_via_compositor = bool(file.get_8())
		OS.window_fullscreen = bool(file.get_8())
		
		var cset = registry_colorset.get_item(file.get_line())
		if cset: select_colorset(cset)
		
		if sv >= 5:
			parallax = file.get_float()
		if sv >= 6:
			cam_unlock = bool(file.get_8())
		
		if sv >= 17: # Integrity check (added in sv 17)
			if file.get_8() != 215:
				print("integ 2"); return 4
		
		if sv >= 7: 
			show_config = bool(file.get_8())
			enable_grid = bool(file.get_8())
		if sv >= 8:
			cursor_scale = file.get_float()
		
		if sv >= 17: # Integrity check (added in sv 17)
			if file.get_8() != 43:
				print("integ 3"); return 5
		
		if sv >= 9:
			edge_drift = file.get_float()
			enable_drift_cursor = bool(file.get_8())
		if sv >= 10:
			hitwindow_ms = file.get_float()
		
		if sv >= 17: # Integrity check (added in sv 17)
			if file.get_8() != 117:
				print("integ 4"); return 6
		
		if sv >= 11:
			cursor_spin = file.get_float()
		if sv >= 12:
			music_volume_db = file.get_float()
		if sv >= 13:
			var world = registry_world.get_item(file.get_line())
			if world:
				select_world(world)
		
		if sv >= 17: # Integrity check (added in sv 17)
			if file.get_8() != 89:
				print("integ 5"); return 7
		
		if sv >= 14:
			enable_border = bool(file.get_8())
		if sv >= 15:
			var mesh = registry_mesh.get_item(file.get_line())
			if mesh:
				select_mesh(mesh)
		if sv >= 16:
			play_menu_music = bool(file.get_8())
		
		if sv >= 17: # Integrity check
			if file.get_8() != 12:
				print("integ 6"); return 8
		
		if sv >= 18:
			note_hitbox_size = float(str(file.get_float())) # fix weirdness with 1.14
		if sv >= 19:
			spawn_distance = file.get_float()
		if sv >= 20:
			set("custom_speed",file.get_float())
			note_spawn_effect = bool(file.get_8())
		if sv >= 21:
			display_true_combo = bool(file.get_8())
		if sv >= 22:
			#cursor_face_velocity = bool(
			file.get_8()#)
		if sv >= 23:
			
			if file.get_8() != 147: # Integrity check
				print("integ 7"); return 9
			
			ui_parallax = file.get_float()
		
		if sv >= 24:
			grid_parallax = file.get_float()
		else:
			# Keep old camera parallax for existing save files
			grid_parallax = 0
			ui_parallax = 0
		
		if sv >= 25:
			fade_length = file.get_float()
		
		if sv < 26 and String(note_hitbox_size) == "1.27":
			# Default hitbox change (this is when we solved 0.13)
			print("0.13 :laugh:")
			note_hitbox_size = 1.140
		
		if sv >= 27:
			show_hit_effect = bool(file.get_8())
		if sv >= 28:
			
			if file.get_8() != 6: # Integrity check
				print("integ 8"); return 10
			
			lock_mouse = bool(file.get_8())
			rainbow_cursor = bool(file.get_8())
			cursor_trail = bool(file.get_8())
		if sv >= 29:
			trail_detail = file.get_32() # some people are insane
			trail_time = file.get_real() # 64-bit float bc small numbers
		if sv >= 30:
			friend_position = file.get_8()
			show_hp_bar = bool(file.get_8())
			show_timer = bool(file.get_8())
			show_left_panel = bool(file.get_8())
			show_right_panel = bool(file.get_8())
			attach_hp_to_grid = bool(file.get_8())
			attach_timer_to_grid = bool(file.get_8())
			rainbow_grid = bool(file.get_8())
			rainbow_hud = bool(file.get_8())
			var had_smart_trail = bool(file.get_8())
			if sv >= 32:
				smart_trail = had_smart_trail
			else:
				# New smart trail system
				alert = "The behavior of the Smart Trail setting has been significantly changed, so it has been turned off. See its description in Settings for the new behavior."
				save_settings()
		if sv >= 31:
			var eff = registry_effect.get_item(file.get_line())
			if eff:
				select_hit_effect(eff)
			
			if file.get_8() != 192: # Integrity check
				print("integ 9"); return 11
			
			hit_effect_at_cursor = bool(file.get_8())
		if sv >= 33:
			show_warnings = bool(file.get_8())
		if sv >= 34:
			should_ask_about_replays = false
			record_replays = bool(file.get_8())
		if sv >= 35:
			alt_cam = bool(file.get_8())
		if sv >= 36:
			show_accuracy_bar = bool(file.get_8())
			show_letter_grade = bool(file.get_8())
			simple_hud = bool(file.get_8())
		if sv >= 37:
			faraway_hud = bool(file.get_8())
		if sv >= 38:
			if sv >= 41:
				music_offset = float(file.get_float())
			else:
				music_offset = float(file.get_32())
		if sv >= 39:
			var eff = registry_effect.get_item(file.get_line())
			if eff:
				select_miss_effect(eff)
			show_miss_effect = bool(file.get_8())
		if sv >= 40:
			auto_maximize = bool(file.get_8())
		if sv >= 42:
			note_visual_approach = bool(file.get_8())
		file.close()
	return 0
func save_settings():
	var file:File = File.new()
	var err:int = file.open(Globals.p("user://settings"),File.WRITE)
	if err == OK:
		file.store_16(current_sf_version)
		file.store_float(approach_rate)
		file.store_float(sensitivity)
		file.store_8(int(play_hit_snd))
		file.store_8(int(play_miss_snd))
		file.store_8(int(auto_preview_song))
		
		file.store_8(0) # integrity check
		
		file.store_8(int(OS.vsync_enabled))
		file.store_8(int(OS.vsync_via_compositor))
		file.store_8(int(OS.window_fullscreen))
		file.store_line(selected_colorset.id)
		file.store_float(parallax)
		file.store_8(int(cam_unlock))
		
		file.store_8(215) # integrity check
		
		file.store_8(int(show_config))
		file.store_8(int(enable_grid))
		file.store_float(cursor_scale)
		
		file.store_8(43) # integrity check
		
		file.store_float(edge_drift)
		file.store_8(int(enable_drift_cursor))
		file.store_float(hitwindow_ms)
		
		file.store_8(117) # integrity check
		
		file.store_float(cursor_spin)
		file.store_float(music_volume_db)
		file.store_line(selected_space.id)
		
		file.store_8(89) # integrity check
		
		file.store_8(int(enable_border))
		file.store_line(selected_mesh.id)
		file.store_8(int(play_menu_music))
		
		file.store_8(12) # integrity check
		
		file.store_float(note_hitbox_size)
		file.store_float(spawn_distance)
		file.store_float(custom_speed)
		file.store_8(int(note_spawn_effect))
		file.store_8(int(display_true_combo))
		file.store_8(int(cursor_face_velocity))
		
		file.store_8(147) # integrity check
		
		file.store_float(ui_parallax)
		file.store_float(grid_parallax)
		file.store_float(fade_length)
		file.store_8(int(show_hit_effect))
		
		file.store_8(6) # integrity check
		
		file.store_8(int(lock_mouse))
		file.store_8(int(rainbow_cursor))
		file.store_8(int(cursor_trail))
		file.store_32(trail_detail)
		file.store_real(trail_time)
		file.store_8(friend_position)
		file.store_8(int(show_hp_bar))
		file.store_8(int(show_timer))
		file.store_8(int(show_left_panel))
		file.store_8(int(show_right_panel))
		file.store_8(int(attach_hp_to_grid))
		file.store_8(int(attach_timer_to_grid))
		file.store_8(int(rainbow_grid))
		file.store_8(int(rainbow_hud))
		file.store_8(int(smart_trail))
		file.store_line(selected_hit_effect.id)
		
		file.store_8(192) # integrity check
		
		file.store_8(int(hit_effect_at_cursor))
		file.store_8(int(show_warnings))
		file.store_8(int(record_replays))
		file.store_8(int(alt_cam))
		file.store_8(int(show_accuracy_bar))
		file.store_8(int(show_letter_grade))
		file.store_8(int(simple_hud))
		file.store_8(int(faraway_hud))
		file.store_float(music_offset)
		file.store_line(selected_miss_effect.id)
		file.store_8(int(show_miss_effect))
		file.store_8(int(auto_maximize))
		file.store_8(int(note_visual_approach))
		
		file.close()
		return "OK"
	else:
		print("error code %s" % err)




# Built-in content data
func register_colorsets():
	registry_colorset.add_item(ColorSet.new(
		[ Color("#fc94f2"),Color("#96fc94") ],
		"ssp_everybodyvotes", "Everybody Votes Channel", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[ Color("#fc4441"), Color("#4151fc") ],
		"ssp_redblue", "Red & Blue", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[ Color("#ffcc4d"),Color("#ff7892"),Color("#e5dd80") ],
		"ssp_veggiestraws", "Veggie Straws", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[ Color("#5BCEFA"),Color("#F5A9B8"),Color("#FFFFFF") ],
		"ssp_pastel", "Pastel", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[
			Color("#e95f5f"), Color("#e88d5f"), Color("#e8ba5f"), Color("#e8e85f"),
			Color("#bae85f"), Color("#8de85f"), Color("#5fe85f"), Color("#5fe88d"),
			Color("#5fe8ba"), Color("#5fe8e8"), Color("#5fbae8"), Color("#5f8de8"),
			Color("#5f5fe8"), Color("#8d5fe8"), Color("#ba5fe8"), Color("#e85fe8"),
			Color("#e85fa4"), Color("#e85f8d"),
		],
		"ssp_hue", "Hue Wheel", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[
			Color("#e95f5f"), Color("#e8765f"), Color("#e88d5f"), Color("#e8a45f"),
			Color("#e8ba5f"), Color("#e8d15f"), Color("#e8e85f"), Color("#d1e85f"),
			Color("#bae85f"), Color("#a4e85f"), Color("#8de85f"), Color("#76e85f"),
			Color("#5fe85f"), Color("#5fe876"), Color("#5fe88d"), Color("#5fe8a4"),
			Color("#5fe8ba"), Color("#5fe8d1"), Color("#5fe8e8"), Color("#5fd1e8"),
			Color("#5fbae8"), Color("#5fa4e8"), Color("#5f8de8"), Color("#5f76e8"),
			Color("#5f5fe8"), Color("#765fe8"), Color("#8d5fe8"), Color("#a45fe8"),
			Color("#ba5fe8"), Color("#d15fe8"), Color("#e85fe8"), Color("#e85fd1"),
			Color("#e85fa4"), Color("#e85f8d"), Color("#e85f8d"), Color("#e85f76"),
		],
		"ssp_hue_ultra", "Hue Wheel Ultra", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[ Color("#ffffff") ],
		"ssp_soul", "SOUL", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[ Color("#9a5ef9") ],
		"ssp_purple", "purple!!!", "Chedski"
	))
	registry_colorset.add_item(ColorSet.new(
		[ Color("#000000"), Color("#381e42") ],
		"ssp_vortex", "Vortex", "pyrule"
	))
func register_worlds():
	# idI:String,nameI:String,pathI:String,creatorI:String="Unknown"
	registry_world.add_item(BackgroundWorld.new(
		"ssp_space_tunnel", "Neon Corners",
		"res://content/worlds/space_tunnel.tscn", "Chedski",
		"res://content/worlds/covers/space_tunnel.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_neon_tunnel", "Neon Rings",
		"res://content/worlds/neon_tunnel.tscn", "Chedski",
		"res://content/worlds/covers/neon_tunnel.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_deep_space", "Deep Space",
		"res://content/worlds/deep_space.tscn", "Chedski",
		"res://content/worlds/covers/deep_space.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_void", "VOID",
		"res://content/worlds/void.tscn", "Chedski",
		"res://content/worlds/covers/void.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_rainbow_road", "Rainbow Road",
		"res://content/worlds/rainbow_road.tscn", "Chedski",
		"res://content/worlds/covers/rainbow_road.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_rainbow_road_nb", "Rainbow Road (no bloom)",
		"res://content/worlds/rainbow_road.tscn", "Chedski",
		"res://content/worlds/covers/rainbow_road.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_cubic", "Cubic",
		"res://content/worlds/cubic.tscn", "Chedski",
		"res://content/worlds/covers/cubic.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_classic", "Beyond",
		"res://content/worlds/classic.tscn", "Chedski",
		"res://content/worlds/covers/classic.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_reality_dismissed", "Reality Dismissed",
		"res://content/worlds/reality_dismissed.tscn", "pyrule",
		"res://content/worlds/covers/custom.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_reality_dismissed_dark", "Reality Dismissed (Dark)",
		"res://content/worlds/reality_dismissed_dark.tscn", "pyrule",
		"res://content/worlds/covers/custom.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_baseplate", "Baseplate (Day)",
		"res://content/worlds/baseplate.tscn", "pyrule",
		"res://content/worlds/covers/baseplate.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_baseplate_night", "Baseplate (Night)",
		"res://content/worlds/baseplate_night.tscn", "pyrule",
		"res://content/worlds/covers/baseplate.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_event_horizon", "Event Horizon",
		"res://content/worlds/event_horizon.tscn", "Chedski",
		"res://content/worlds/covers/custom.png"
	))
	
	registry_world.add_item(BackgroundWorld.new(
		"ssp_custombg", "Custom Background",
		"res://content/worlds/custombg.tscn", "Someone",
		"res://error.jpg"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_custom", "Modworld (info in the discord)",
		"res://content/worlds/custom.tscn", "Someone",
		"res://content/worlds/covers/custom.png"
	))

func register_meshes():
	registry_mesh.add_item(NoteMesh.new(
		"ssp_square", "Square",
		"res://content/blocks/default.obj", "Chedski"
	))
	registry_mesh.add_item(NoteMesh.new(
		"ssp_rounded", "Rounded",
		"res://content/blocks/rounded.obj", "Chedski"
	))
	registry_mesh.add_item(NoteMesh.new(
		"ssp_circle", "Circle",
		"res://content/blocks/circle.obj", "Chedski"
	))
	registry_mesh.add_item(NoteMesh.new(
		"ssp_block", "Block",
		"res://content/blocks/cube.obj", "Chedski"
	))
	registry_mesh.add_item(NoteMesh.new(
		"ssp_plane", "Front of Block",
		"res://content/blocks/plane.obj", "Chedski"
	))
func register_effects():
	registry_effect.add_item(NoteEffect.new(
		"ssp_ripple", "Ripple* (no color)", "res://content/notefx/ripple.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_ripple_n", "Ripple* (note color)", "res://content/notefx/ripple.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_ripple_r", "Ripple* (rainbow)", "res://content/notefx/ripple.tscn", "Chedski"
	))
	
	registry_effect.add_item(NoteEffect.new(
		"ssp_shards", "Shards (note color)", "res://content/notefx/shards.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_shards_r", "Shards (rainbow)", "res://content/notefx/shards.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_shards_w", "Shards (no color)", "res://content/notefx/shards.tscn", "Chedski"
	))
	
	registry_effect.add_item(NoteEffect.new(
		"ssp_miss", "Miss* (red)", "res://content/notefx/miss.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_miss_n", "Miss* (note color)", "res://content/notefx/miss.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_miss_r", "Miss* (rainbow)", "res://content/notefx/miss.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_miss_w", "Miss* (no color)", "res://content/notefx/miss.tscn", "Chedski"
	))




# User colorsets
signal colors_done
func load_color_txt(path:String="",id:String=""):
	if path == "" and id == "":
		yield(get_tree(),"idle_frame")
		load_color_folder()
		return
	
	var regex:RegEx = RegEx.new()
	regex.compile("#?([a-zA-Z\\d]{2})([a-zA-Z\\d]{2})([a-zA-Z\\d]{2})([a-zA-Z\\d]{2})?")
	
	var cfname:String = "colors.txt (1 per line)"
	if id != "colorsfile":
		cfname = path.get_file().get_basename()
	var cf:ColorSet 
	
	if registry_colorset.idx_id.has(id):
		cf = registry_colorset.get_item(id)
	else:
		cf = ColorSet.new([],id,cfname,"Someone")
		registry_colorset.add_item(cf)
	
	var file:File = File.new()
	if file.file_exists(Globals.p(path)):
		var err:int = file.open(Globals.p(path),File.READ)
		if err == OK:
			var ctxt:String = file.get_as_text()
			file.close()
			var split:Array = ctxt.split("\n",false)
			var colarr:Array = []
			var mirror = false
			for st in split:
				if st.strip_edges().is_valid_html_color():
					colarr.append(Color(st.strip_edges()))
				elif st.to_lower() == "m":
					mirror = true
			cf.mirror = mirror
			
			if colarr.size() == 0:
				print("no valid colors found")
				colarr = [ Color("#ffffff") ]
			
			cf.colors = colarr
			return
		else: print("couldnt open %s because error %s" % [path,err])
	else: print("no colors.txt")
	cf.colors = [ Color("#ffffff") ]
func load_color_folder():
	var a = OS.get_ticks_usec()
	print("(re)load custom colorsets")
	load_color_txt("user://colors.txt","colorsfile")
	var dir:Directory = Directory.new()
	if dir.dir_exists(user_colorset_dir):
		var files = Globals.get_files_recursive([user_colorset_dir],5)
		var i = 0
		for n in files.files:
			var b = OS.get_ticks_usec()
			load_color_txt(n,"custom_" + n.get_file().to_lower().md5_text())
			i += 1
			if fmod(i,4) == 0: yield(get_tree(),"idle_frame")
			n = dir.get_next()
			print("set %s took %s usec" % [i,Globals.comma_sep(OS.get_ticks_usec() - b)])
	print("colorsets took %s usec" % [Globals.comma_sep(OS.get_ticks_usec() - a)])
	emit_signal("colors_done")

# Initialization
func do_init(_ud=null):
	installed_packs = []
	yield(get_tree().create_timer(0.05),"timeout") # haha thread safety go brrrr
	var lp:bool = false # load pause
	var file:File = File.new()
	var dir:Directory = Directory.new()
	
	emit_signal("init_stage_reached","Init filesystem")
	yield(get_tree(),"idle_frame")
	if OS.has_feature("Android"): OS.request_permissions()
	var user_dir = Globals.p("user://")
	if user_dir == "RETRY":
		yield(get_tree().create_timer(7),"timeout")
		user_dir = Globals.p("user://")
	var err:int = dir.open(user_dir)
	if OS.has_feature("editor"):
		yield(get_tree().create_timer(0.35),"timeout")
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_U):
		err = -1
	
	if err != OK:
		Globals.errornum = err
		get_tree().change_scene("res://errors/userfolder.tscn")
		return
	
	# Setup directories if they don't already exist
	var convert_pb_format:bool = false
	
	if !first_init_done:
		if !dir.dir_exists(user_mod_dir): dir.make_dir(user_mod_dir)
		if !dir.dir_exists(user_pack_dir): dir.make_dir(user_pack_dir)
		if !dir.dir_exists(user_vmap_dir): dir.make_dir(user_vmap_dir)
		if !dir.dir_exists(user_map_dir): dir.make_dir(user_map_dir)
		if !dir.dir_exists(Globals.p("user://replays")): dir.make_dir(Globals.p("user://replays"))
		if !dir.dir_exists(user_best_dir):
			convert_pb_format = true
			dir.make_dir(user_best_dir)
	
	# set up registries
	emit_signal("init_stage_reached","Init registries")
	if lp: yield(get_tree(),"idle_frame")
	registry_colorset = Registry.new()
	registry_song = Registry.new()
	registry_world = Registry.new()
	registry_mesh = Registry.new()
	registry_effect = Registry.new()
	
	Online.map_registry = registry_song
	
	register_colorsets()
	register_effects()
	register_meshes()
	register_worlds()
	
	# init colors.txt
	emit_signal("init_stage_reached","Load user colorsets")
	registry_colorset.add_item(ColorSet.new(
		[ Color("#ffffff") ],
		"colorsfile", "colors.txt (1 per line)", "Someone"
	))
	load_color_txt()
	yield(self,"colors_done")
	
	# Load content
	var mapreg:Array = []
	emit_signal("init_stage_reached","Loading content 1/3\nBuilt-in & DLC")
	yield(get_tree(),"idle_frame")
	if first_init_done:
		mapreg.append(["built-in","res://content/songs/built_in_maps.sspmr"])
		if installed_dlc.has("ssp_testcontent"): mapreg.append(["test maps","res://test_assets/test_maps.sspmr"])
	else:
		print("loaded ssp_content DLC")
		mapreg.append(["built-in","res://content/songs/built_in_maps.sspmr"])
		installed_dlc.append("ssp_content")
		if OS.has_feature("editor") or ProjectSettings.load_resource_pack("res://testcontent.pck"):
			print("loaded ssp_testcontent DLC")
			mapreg.append(["test maps","res://test_assets/test_maps.sspmr"])
			installed_dlc.append("ssp_testcontent")
	
	var n
	if !first_init_done: # mods can't be reloaded
		emit_signal("init_stage_reached","Loading content 2/3\nMods")
		yield(get_tree(),"idle_frame")
		dir.change_dir(user_mod_dir)
		dir.list_dir_begin(true)
		n = dir.get_next()
		while n:
			if ProjectSettings.load_resource_pack(user_mod_dir + "/" + n):
				installed_mods.append(n.get_file().replace(n.get_extension(),""))
			n = dir.get_next()
		dir.list_dir_end()
	
	emit_signal("init_stage_reached","Loading content 3/3\nContent packs")
	yield(get_tree(),"idle_frame")
	dir.change_dir(user_pack_dir)
	dir.list_dir_begin(true)
	n = dir.get_next()
	while n:
		installed_packs.append([n.get_file(),user_pack_dir + "/" + n])
		if dir.file_exists(n + "/pack.sspmr"): mapreg.append([n.get_file(),user_pack_dir + "/" + n + "/pack.sspmr"])
		n = dir.get_next()
	dir.list_dir_end()
	
	
	emit_signal("init_stage_reached","Register content")
	yield(get_tree(),"idle_frame")
	
	var smaps:Array = []
	emit_signal("init_stage_reached","Register content 1/4\nImport SS+ maps\nLocating files")
	yield(get_tree(),"idle_frame")
	var sd:Array = []
	dir.change_dir(user_map_dir)
	var li = 0
	
	var map_search_folders = [user_map_dir]
	err = file.open(Globals.p("user://map_folders.txt"),File.READ)
	if err == OK:
		var txt = file.get_as_text()
		var list = txt.split("\n",false)
		map_search_folders.append_array(list)
	
	Globals.get_files_recursive(map_search_folders,5,"sspm","",90)
	smaps = yield(Globals,"recurse_result").files
	
	for i in range(smaps.size()):
		emit_signal("init_stage_reached","Register content 1/4\nImport SS+ maps\n%.0f%%" % (
			100*(float(i)/float(smaps.size()))
		))
		if fmod(i,max(min(floor(float(smaps.size())/200),40),5)) == 0: yield(get_tree(),"idle_frame")
		registry_song.add_sspm_map(smaps[i])
#	dir.list_dir_end()
	
	for i in range(mapreg.size()):
		var amr:Array = mapreg[i]
		emit_signal("init_stage_reached","Register content 2/4\nLoad map registry %d/%d\n%s" % [i,mapreg.size(),amr[0]])
		yield(get_tree(),"idle_frame")
		if lp: yield(get_tree(),"idle_frame")
		registry_song.load_registry_file(amr[1],Globals.REGISTRY_MAP,amr[0])
		yield(registry_song,"done_loading_reg")
	
	var vmaps:Array = []
	
	var vmap_search_folders = [user_vmap_dir]
	err = file.open(Globals.p("user://vmap_folders.txt"),File.READ)
	if err == OK:
		var txt = file.get_as_text()
		var list = txt.split("\n",false)
		vmap_search_folders.append_array(list)
	
	emit_signal("init_stage_reached","Register content 3/4\nImport Vulnus maps\nLocating files")
	yield(get_tree(),"idle_frame")
	
	Globals.get_files_recursive(vmap_search_folders,6,"","meta.json",70)
	vmaps = yield(Globals,"recurse_result").folders
	
	for i in range(vmaps.size()):
		emit_signal("init_stage_reached","Register content 3/4\nImport Vulnus maps\n%.0f%%" % (
			100*(float(i)/float(vmaps.size()))
		))
		if fmod(i,floor(float(vmaps.size())/100)) == 0: yield(get_tree(),"idle_frame")
		registry_song.add_vulnus_map(vmaps[i])
	
	emit_signal("init_stage_reached","Register content 4/4\nLoad online maps")
	yield(get_tree(),"idle_frame")
	
	Online.load_db_maps()
	yield(Online,"db_maps_done")
	
	# Default 
	emit_signal("init_stage_reached","Init default assets")
	yield(get_tree(),"idle_frame")
	
	emit_signal("init_stage_reached","Init default assets 1/6")
	if lp: yield(get_tree(),"idle_frame")
	selected_hit_effect = registry_effect.get_item("ssp_ripple")
	selected_miss_effect = registry_effect.get_item("ssp_miss")
	selected_colorset = registry_colorset.get_item("ssp_everybodyvotes")
	selected_space = registry_world.get_item("ssp_space_tunnel")
	selected_mesh = registry_mesh.get_item("ssp_rounded")
	
	assert(selected_hit_effect)
	assert(selected_miss_effect)
	assert(selected_colorset)
	assert(selected_space)
	assert(selected_mesh)
	
	emit_signal("init_stage_reached","Init default assets 2/6")
	if lp: yield(get_tree(),"idle_frame")
	def_miss_snd = load("res://content/sfx/miss.wav")
	
	emit_signal("init_stage_reached","Init default assets 3/6")
	if lp: yield(get_tree(),"idle_frame")
	def_hit_snd = load("res://content/sfx/hit.wav")
	
	emit_signal("init_stage_reached","Init default assets 4/6")
	if lp: yield(get_tree(),"idle_frame")
	def_fail_snd = load("res://content/sfx/fail.wav")
	
	emit_signal("init_stage_reached","Init default assets 5/6")
	if lp: yield(get_tree(),"idle_frame")
	def_pb_snd = load("res://content/sfx/new_best.wav")
	normal_pb_sound = def_pb_snd
	
	emit_signal("init_stage_reached","Init default assets 6/6")
	if lp: yield(get_tree(),"idle_frame")
	def_menu_bgm = load("res://content/sfx/music/menu_loop.ogg")
	
	# Read settings
	emit_signal("init_stage_reached","Read user settings")
	yield(get_tree(),"idle_frame")
	var result = load_saved_settings()
	if result != 0:
		errornum = result
		# errors are returned when settings are invalid
		get_tree().change_scene("res://errors/settings.tscn")
		return
	print('settings done')
	
	# Get custom sounds
	emit_signal("init_stage_reached","Load custom assets")
	yield(get_tree(),"idle_frame")
	
	emit_signal("init_stage_reached","Load asset replacement 1/5\nmiss")
	if lp: yield(get_tree(),"idle_frame")
	miss_snd = get_stream_with_default("user://miss",def_miss_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 2/5\nhit")
	if lp: yield(get_tree(),"idle_frame")
	hit_snd = get_stream_with_default("user://hit",def_hit_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 3/5\nfail")
	if lp: yield(get_tree(),"idle_frame")
	fail_snd = get_stream_with_default("user://fail",def_fail_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 4/5\nnew_best")
	if lp: yield(get_tree(),"idle_frame")
	pb_snd = get_stream_with_default("user://new_best",def_pb_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 5/5\nmenu")
	if lp: yield(get_tree(),"idle_frame")
	menu_bgm = get_stream_with_default("user://menu",def_menu_bgm)
	
	fail_asp.stream = fail_snd
	Globals.error_sound = miss_snd
	
	# Read PB data
	if convert_pb_format:
		hitwindow_ms = 55
		note_hitbox_size = 1.14
		
		emit_signal("init_stage_reached","Upgrading personal best data\nReading legacy data")
		yield(get_tree(),"idle_frame")
		load_pbs()
		
		emit_signal("init_stage_reached","Upgrading personal best data\nPreparing")
		yield(get_tree(),"idle_frame")
		var allmaps:Array = registry_song.get_items()
		
		emit_signal("init_stage_reached","Upgrading personal best data\nConverting data\n0%")
		yield(get_tree(),"idle_frame")
		for i in range(allmaps.size()):
			emit_signal("init_stage_reached","Upgrading personal best data\nConverting data\n%.0f%%" % (
				100*(float(i)/float(allmaps.size()))
			))
			if fmod(i,max(min(floor(float(allmaps.size())/200),40),5)) == 0: yield(get_tree(),"idle_frame")
			convert_song_pbs(allmaps[i])
	
	# Load favorite songs
	# Check if VR is available
	if !first_init_done:
		
		# Favorite songs
		emit_signal("init_stage_reached","Read favorite songs")
		yield(get_tree(),"idle_frame")
		if file.file_exists(Globals.p("user://favorites.txt")):
			file.open(Globals.p("user://favorites.txt"),File.READ)
			var txt = file.get_as_text()
			file.close()
			favorite_songs = txt.split("\n",false)
		
		# VR
		emit_signal("init_stage_reached","Check VR status")
		yield(get_tree(),"idle_frame")
		
		var interface = ARVRServer.find_interface("OpenVR")
		if interface:
			vr_interface = interface
			vr_available = true
	
	dir.change_dir("res://")
	first_init_done = true
	do_archive_convert = false
	
	if Input.is_key_pressed(KEY_W):
		alert = "Test alert"
	
	var alert_snd_played:bool = false
	if alert != "":
		emit_signal("init_stage_reached","Alert prompt")
		if !alert_snd_played: Globals.confirm_prompt.s_alert.play()
		alert_snd_played = true
		Globals.confirm_prompt.open(alert,"Alert",[{text="OK",wait=2}])
		yield(Globals.confirm_prompt,"option_selected")
		Globals.confirm_prompt.s_next.play()
		Globals.confirm_prompt.close()
		yield(Globals.confirm_prompt,"done_closing")
	if should_ask_about_replays:
		emit_signal("init_stage_reached","Setup")
		if !alert_snd_played: Globals.confirm_prompt.s_alert.play()
		alert_snd_played = true
		Globals.confirm_prompt.open("Would you like to record replays? This can be changed in settings later.","Replays",[{text="No"},{text="Yes"}])
		var sel = yield(Globals.confirm_prompt,"option_selected")
		record_replays = bool(sel)
		save_settings()
		Globals.confirm_prompt.s_next.play()
		Globals.confirm_prompt.close()
		yield(Globals.confirm_prompt,"done_closing")
	emit_signal("init_stage_reached","Waiting for menu",true)

