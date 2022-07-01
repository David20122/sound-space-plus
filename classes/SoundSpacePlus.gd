extends Node

# Signals
signal mods_changed
signal speed_mod_changed
signal selected_song_changed
signal selected_space_changed
signal selected_colorset_changed
signal selected_mesh_changed
signal selected_hit_effect_changed
signal init_stage_reached
signal map_list_ready
signal volume_changed
signal favorite_songs_changed
signal menu_music_state_changed

# Song ending
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

# Selected items
var selected_space:BackgroundWorld
var selected_colorset:ColorSet
var selected_song:Song
var selected_mesh:NoteMesh
var selected_hit_effect:NoteEffect
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

# Mods
var mod_extra_energy:bool = false setget set_mod_extra_energy # Easy Mode
var mod_no_regen:bool = false setget set_mod_no_regen # Hard Mode
var mod_speed_level:int = Globals.SPEED_NORMAL setget set_mod_speed_level
var mod_nofail:bool = false setget set_mod_nofail
var mod_mirror_x:bool = false setget set_mod_mirror_x
var mod_mirror_y:bool = false setget set_mod_mirror_y
var mod_nearsighted:bool = false setget set_mod_nearsighted
var mod_ghost:bool = false setget set_mod_ghost
var mod_sudden_death:bool = false setget set_mod_sudden_death

var menu_target:String = ProjectSettings.get_setting("application/config/default_menu_target")

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

# Registries
var registry_colorset:Registry
var registry_song:Registry
var registry_world:Registry
var registry_mesh:Registry
var registry_effect:Registry

# Content management
var user_pack_dir:String = Globals.p("user://packs")
var user_mod_dir:String = Globals.p("user://mods")
var user_vmap_dir:String = Globals.p("user://vmaps")
var user_map_dir:String = Globals.p("user://maps")
var user_best_dir:String = Globals.p("user://bests")
var installed_dlc:Array = ["ssp_basegame"]
var installed_mods:Array = []
var installed_packs:Array = []

# User settings
var play_hit_snd:bool = true
var play_miss_snd:bool = true
var approach_rate:float = 50
var sensitivity:float = 1
var parallax:float = 1
var ui_parallax:float = 0.2
var grid_parallax:float = 3
var camera_mode:int = Globals.CAMERA_HALF_LOCK
var auto_preview_song:bool = true
var cam_unlock:bool = false
var show_config:bool = true
var enable_grid:bool = true
var enable_border:bool = true
var cursor_scale:float = 1
var edge_drift:float = 0
var enable_drift_cursor:bool = true
var cursor_spin:float = 0
var spawn_distance:float = 100
var note_spawn_effect:bool = true
var display_true_combo:bool = true
var cursor_face_velocity:bool = false
var show_hit_effect:bool = true
var hit_effect_at_cursor:bool = true
var lock_mouse:bool = true
var show_warnings:bool = true
var fade_length:float = 0.5

var record_replays:bool = ProjectSettings.get_setting("application/config/replays")
var replay:Replay
var replay_path:String = ""
var was_replay:bool = false
var replaying:bool = false
var alt_cam:bool = false

var rainbow_cursor:bool = false
var cursor_trail:bool = false
var smart_trail:bool = false
var trail_detail:int = 10
var trail_time:float = 0.15

var friend_position:int = Globals.FRIEND_BEHIND_GRID

var show_hp_bar:bool = true
var show_timer:bool = true
var show_left_panel:bool = true
var show_right_panel:bool = true
var attach_hp_to_grid:bool = false
var attach_timer_to_grid:bool = false

var rainbow_grid:bool = false
var rainbow_hud:bool = false

var note_hitbox_size:float = 1.140 setget _set_hitbox_size
func _set_hitbox_size(v:float):
	
	note_hitbox_size = v; emit_signal("mods_changed")

var hitwindow_ms:float = 55 setget _set_hitwindow
func _set_hitwindow(v:float):
	hitwindow_ms = v; emit_signal("mods_changed")

var custom_speed:float = 1 setget _set_custom_speed
func _set_custom_speed(v:float):
	print("custom speed changed")
	custom_speed = v
	Globals.speed_multi[Globals.SPEED_CUSTOM] = v
	emit_signal("mods_changed")
	emit_signal("speed_mod_changed")

var health_model:int = Globals.HP_SOUNDSPACE setget _set_health_model
func _set_health_model(v:int):
	health_model = v; emit_signal("mods_changed")

var play_menu_music:bool = false setget _set_menu_music
func _set_menu_music(v:bool):
	play_menu_music = v; emit_signal("menu_music_state_changed")

var music_volume_db:float = 0 setget _set_music_volume
func _set_music_volume(v:float):
	music_volume_db = v; emit_signal("volume_changed")

var miss_snd:AudioStream
var hit_snd:AudioStream
var fail_snd:AudioStream
var pb_snd:AudioStream
var menu_bgm:AudioStream

var def_miss_snd:AudioStream
var def_hit_snd:AudioStream
var def_fail_snd:AudioStream
var def_pb_snd:AudioStream
var def_menu_bgm:AudioStream

var loaded_world = null

# Other save data
var personal_bests:Dictionary = {}
var favorite_songs:Array = []

var do_archive_convert:bool = false
var conmgr_transit = null

func save_favorites():
	var file:File = File.new()
	file.open(Globals.p("user://favorites.txt"),File.WRITE)
	var txt:String = ""
	for s in favorite_songs:
		if s != favorite_songs[0]: txt += "\n"
		txt += s
	file.store_line(txt)
	file.close()

func is_favorite(id:String): return favorite_songs.has(id)

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


func save_pbs():
	pass

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

func generate_pb_str():
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
	if music_volume_db <= -50: pts.append("silent")
	
	if mod_sudden_death: pts.append("m_sd")
	if mod_extra_energy: pts.append("m_morehp")
	if mod_no_regen: pts.append("m_noregen")
	if mod_mirror_x: pts.append("m_mirror_x")
	if mod_mirror_y: pts.append("m_mirror_y")
	if mod_nearsighted: pts.append("m_nsight")
	if mod_ghost: pts.append("m_ghost")
	if mod_sudden_death: pts.append("m_sd")
	
	pts.sort()
	
	var s:String = ""
	for i in range(pts.size()):
		if i != 0: s += ";"
		s += pts[i]
	
	return s

func parse_pb_str(txt:String):
	var data:Dictionary = {}
	var pts:Array = txt.split(";",false)
	data.health_model = Globals.HP_SOUNDSPACE
	
	data.mod_sudden_death = false
	data.mod_extra_energy = false
	data.mod_no_regen = false
	data.mod_mirror_x = false
	data.mod_mirror_y = false
	data.mod_nearsighted = false
	data.mod_ghost = false
	
	for s in pts:
		if s.begins_with("s:c"):
			data.mod_speed_level = Globals.SPEED_CUSTOM
			data.custom_speed = float(s.substr(3))
		elif s.begins_with("hitw:"):
			data.hitwindow_ms = float(s.substr(5))
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
	return data

var prev_state:Dictionary = {}
func save_current_state(): prev_state = parse_pb_str(generate_pb_str())
func restore_prev_state(): for k in prev_state.keys(): set(k,prev_state.get(k))
func apply_state(state:Dictionary): for k in state.keys(): set(k,state.get(k))

func set_pb(songid:String,pbtype:int):
	var pb = personal_bests[songid][pbtype]
	pb.position = song_end_position
	pb.length = song_end_length
	pb.hit_notes = song_end_hits
	pb.total_notes = song_end_total_notes
	pb.pauses = song_end_pause_count
	pb.has_passed = song_end_type == Globals.END_PASS
	save_pbs()

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
		song.set_pb_if_better(generate_pb_str(),npb)

func prepare_new_pb(songid:String):
	var data = {
		mod_extra_energy = mod_extra_energy,
		mod_no_regen = mod_no_regen,
		mod_speed_level = mod_speed_level
	}
	if not personal_bests.has(songid): personal_bests[songid] = []
	var i = personal_bests[songid].size()
	personal_bests[songid].append(data)
	set_pb(songid,i)

func do_pb_check_and_set() -> bool:
	if mod_nofail or was_replay: return false
	var has_passed:bool = song_end_type == Globals.END_PASS
	var pb:Dictionary = {}
	pb.position = song_end_position
	pb.length = song_end_length
	pb.hit_notes = song_end_hits
	pb.total_notes = song_end_total_notes
	pb.pauses = song_end_pause_count
	pb.has_passed = song_end_type == Globals.END_PASS
	return selected_song.set_pb_if_better(generate_pb_str(),pb)

func get_best():
	return selected_song.get_pb(generate_pb_str())


func select_colorset(set:ColorSet):
	if set:
		selected_colorset = set
		emit_signal("selected_colorset_changed",set)

func select_world(world:BackgroundWorld):
	if world:
		selected_space = world
		emit_signal("selected_space_changed",world)

func select_song(song:Song):
	selected_song = song
	emit_signal("selected_song_changed",song)

func select_mesh(mesh:NoteMesh):
	selected_mesh = mesh
	emit_signal("selected_mesh_changed",mesh)

func select_hit_effect(effect:NoteEffect):
	if effect:
		selected_hit_effect = effect
		emit_signal("selected_hit_effect_changed",effect)

var rainbow_t:float = 0
func _process(delta):
	rainbow_t = fmod(rainbow_t + (delta*0.5),10)
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen


func update_rpc_song():
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

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
#	if result != Discord.Result.Ok:
#		push_error(result)


const current_sf_version = 34
var alert:String = ""
var should_ask_about_replays:bool = true

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
		
		if sv >= 5: parallax = file.get_float()
		if sv >= 6: cam_unlock = bool(file.get_8())
		if sv >= 17: if file.get_8() != 215:
			print("integ 2"); return 4
		if sv >= 7: 
			show_config = bool(file.get_8())
			enable_grid = bool(file.get_8())
		if sv >= 8: cursor_scale = file.get_float()
		if sv >= 17: if file.get_8() != 43:
			print("integ 3"); return 5
		if sv >= 9:
			edge_drift = file.get_float()
			enable_drift_cursor = bool(file.get_8())
		if sv >= 10: hitwindow_ms = file.get_float()
		if sv >= 17: if file.get_8() != 117:
			print("integ 4"); return 6
		if sv >= 11: cursor_spin = file.get_float()
		if sv >= 12: music_volume_db = file.get_float()
		if sv >= 13:
			var world = registry_world.get_item(file.get_line())
			if world: select_world(world)
		if sv >= 17: if file.get_8() != 89:
			print("integ 5"); return 7
		if sv >= 14: enable_border = bool(file.get_8())
		if sv >= 15:
			var mesh = registry_mesh.get_item(file.get_line())
			if mesh: select_mesh(mesh)
		if sv >= 16: play_menu_music = bool(file.get_8())
		if sv >= 17: if file.get_8() != 12:
			print("integ 6"); return 8
		if sv >= 18: note_hitbox_size = float(str(file.get_float())) # fix weirdness with 1.14
		if sv >= 19: spawn_distance = file.get_float()
		if sv >= 20:
			custom_speed = file.get_float()
			note_spawn_effect = bool(file.get_8())
		if sv >= 21:
			display_true_combo = bool(file.get_8())
		if sv >= 22:
			cursor_face_velocity = bool(file.get_8())
		if sv >= 23:
			if file.get_8() != 147:
				print("integ 7"); return 9
			ui_parallax = file.get_float()
		if sv >= 24:
			grid_parallax = file.get_float()
		else:
			grid_parallax = 0
			ui_parallax = 0
		if sv >= 25: fade_length = file.get_float()
		if sv < 26 and String(note_hitbox_size) == "1.27":
			print("0.13 :laugh:")
			note_hitbox_size = 1.140
		if sv >= 27:
			show_hit_effect = bool(file.get_8())
		if sv >= 28:
			if file.get_8() != 6:
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
			if sv >= 32: smart_trail = had_smart_trail
			else:
				alert = "The behavior of the Smart Trail setting has been significantly changed, so it has been turned off. See its description in Settings for the new behavior."
				save_settings()
		if sv >= 31:
			var en = file.get_line()
			print(en)
			var eff = registry_effect.get_item(en)
			print(eff)
			if eff: select_hit_effect(eff)
			if file.get_8() != 192:
				print("integ 9"); return 11
			hit_effect_at_cursor = bool(file.get_8())
		if sv >= 33:
			show_warnings = bool(file.get_8())
		if sv >= 34:
			should_ask_about_replays = false
			record_replays = bool(file.get_8())
		if sv >= 35:
			alt_cam = bool(file.get_8())
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
		file.close()
		return "OK"
	else:
		print("error code %s" % err)

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

var first_init_done = false
var normal_pb_sound
var fail_asp:AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	fail_asp.volume_db = -10
	call_deferred("add_child",fail_asp)
	pause_mode = PAUSE_MODE_PROCESS

var errornum:int = 0
var errorstr:String = ""

# separated these, should hopefully make them easier to find
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
		"ssp_transgender", "Trans Pride", "Chedski"
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
		"ssp_custombg", "Custom Background",
		"res://content/worlds/custombg.tscn", "Someone",
		"res://error.jpg"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_custom", "Custom (info in the discord)",
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

func register_effects():
	registry_effect.add_item(NoteEffect.new(
		"ssp_ripple", "Ripple* (no color)",
		"res://content/notefx/ripple.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_ripple_n", "Ripple* (note color)",
		"res://content/notefx/ripple.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_ripple_r", "Ripple* (rainbow)",
		"res://content/notefx/ripple.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_shards", "Shards (note color)",
		"res://content/notefx/shards.tscn", "Chedski"
	))
	registry_effect.add_item(NoteEffect.new(
		"ssp_shards_r", "Shards (rainbow)",
		"res://content/notefx/shards.tscn", "Chedski"
	))

func load_color_txt():
	print("(re)load custom colors file")
	var regex:RegEx = RegEx.new()
	regex.compile("#?([a-zA-Z\\d]{2})([a-zA-Z\\d]{2})([a-zA-Z\\d]{2})([a-zA-Z\\d]{2})?")
	
	var cf:ColorSet = registry_colorset.get_item("colorsfile")
	if !cf: push_error("somehow colorsfile wasnt created")
	
	var file:File = File.new()
	if file.file_exists(Globals.p("user://colors.txt")):
		var err:int = file.open(Globals.p("user://colors.txt"),File.READ)
		if err == OK:
			var ctxt:String = file.get_as_text()
			file.close()
			var split:Array = ctxt.split("\n",false)
			var colarr:Array = []
			for st in split:
				if st.strip_edges().is_valid_html_color():
					colarr.append(Color(st.strip_edges()))
			
			if colarr.size() == 0:
				print("no valid colors found")
				colarr = [ Color("#ffffff") ]
			
			cf.colors = colarr
			return
		else: print("couldnt open colors.txt because error %s" % err)
	else: print("no colors.txt")
	cf.colors = [ Color("#ffffff") ]

func do_init(_ud=null):
	installed_packs = []
	var lmid
	yield(get_tree().create_timer(0.05),"timeout") # haha thread safety go brrrr
	if first_init_done and selected_song: lmid = selected_song.id
	var lp:bool = false # load pause
	var file:File = File.new()
	var dir:Directory = Directory.new()
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
		emit_signal("init_stage_reached","Init filesystem")
		if lp: yield(get_tree(),"idle_frame")
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
	
	register_colorsets()
	register_effects()
	register_meshes()
	register_worlds()
	
	# init colors.txt
	registry_colorset.add_item(ColorSet.new(
		[ Color("#ffffff") ],
		"colorsfile", "colors.txt (1 per line)", "You!"
	))
	load_color_txt()
	
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
	emit_signal("init_stage_reached","Register content 1/4\nImport SS+ maps")
	yield(get_tree(),"idle_frame")
	var sd:Array = []
	dir.change_dir(user_map_dir)
	dir.list_dir_begin(true)
	n = dir.get_next()
	var li = 0
	while n:
		if n.ends_with(".sspm"): smaps.append(n)
		elif dir.dir_exists(n) or n.ends_with(".zip"): sd.append(n)
		n = dir.get_next()
		li += 1
		if fmod(li,100) == 0: yield(get_tree(),"idle_frame")
	for d in sd:
		li += 1
		if fmod(li,100) == 0: yield(get_tree(),"idle_frame")
		dir.change_dir(d)
		if dir.current_is_dir():
			dir.list_dir_begin(true)
			n = dir.get_next()
			while n:
				if n.ends_with(".sspm"): smaps.append(d + "/" + n)
				n = dir.get_next()
				li += 1
				if fmod(li,100) == 0: yield(get_tree(),"idle_frame")
	for i in range(smaps.size()):
		emit_signal("init_stage_reached","Register content 1/4\nImport SS+ maps\n%.0f%%" % (
			100*(float(i)/float(smaps.size()))
		))
		if fmod(i,max(min(floor(float(smaps.size())/200),40),5)) == 0: yield(get_tree(),"idle_frame")
		registry_song.add_sspm_map(user_map_dir + "/" + smaps[i])
	dir.list_dir_end()
	
	for i in range(mapreg.size()):
		var amr:Array = mapreg[i]
		emit_signal("init_stage_reached","Register content 2/4\nLoad map registry %d/%d\n%s" % [i,mapreg.size(),amr[0]])
		yield(get_tree(),"idle_frame")
		if lp: yield(get_tree(),"idle_frame")
		registry_song.load_registry_file(amr[1],Globals.REGISTRY_MAP,amr[0])
		yield(registry_song,"done_loading_reg")
	
	var vmaps:Array = []
	emit_signal("init_stage_reached","Register content 3/4\nImport Vulnus maps")
	yield(get_tree(),"idle_frame")
	dir.change_dir(user_vmap_dir)
	dir.list_dir_begin(true)
	n = dir.get_next()
	while n:
		vmaps.append(n)
		n = dir.get_next()
	for i in range(vmaps.size()):
		emit_signal("init_stage_reached","Register content 3/4\nImport Vulnus maps\n%.0f%%" % (
			100*(float(i)/float(vmaps.size()))
		))
		if fmod(i,floor(float(vmaps.size())/100)) == 0: yield(get_tree(),"idle_frame")
		registry_song.add_vulnus_map(user_vmap_dir + "/" + vmaps[i])
	dir.list_dir_end()
	if dir.dir_exists(Globals.p("user://officialmaps")):
		var vmaps_o:Array = []
		emit_signal("init_stage_reached","Register content 4/4\nImport official map archive")
		yield(get_tree(),"idle_frame")
		dir.change_dir(Globals.p("user://officialmaps"))
		dir.list_dir_begin(true)
		n = dir.get_next()
		while n:
			vmaps_o.append(n)
			n = dir.get_next()
		for i in range(vmaps_o.size()):
			emit_signal("init_stage_reached","Register content 4/4\nImport official map archive\n%.0f%%" % (
				100*(float(i)/float(vmaps_o.size()))
			))
			if fmod(i,floor(float(vmaps_o.size())/100)) == 0: yield(get_tree(),"idle_frame")
			registry_song.add_vulnus_map(Globals.p("user://officialmaps/") + vmaps_o[i])
		dir.list_dir_end()
	
	# Default 
	emit_signal("init_stage_reached","Init default assets")
	yield(get_tree(),"idle_frame")
	
	emit_signal("init_stage_reached","Init default assets 1/6")
	if lp: yield(get_tree(),"idle_frame")
	selected_hit_effect = registry_effect.get_item("ssp_ripple")
	selected_colorset = registry_colorset.get_item("ssp_everybodyvotes")
	selected_space = registry_world.get_item("ssp_space_tunnel")
	selected_mesh = registry_mesh.get_item("ssp_square")
	
	assert(selected_hit_effect)
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
	
	if !first_init_done:
		emit_signal("init_stage_reached","Read favorite songs")
		yield(get_tree(),"idle_frame")
		if file.file_exists(Globals.p("user://favorites.txt")):
			file.open(Globals.p("user://favorites.txt"),File.READ)
			var txt = file.get_as_text()
			file.close()
			favorite_songs = txt.split("\n")
	
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

