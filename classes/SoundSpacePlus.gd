extends Node

# Signals
signal mods_changed
signal speed_mod_changed
signal selected_song_changed
signal selected_space_changed
signal selected_colorset_changed
signal selected_mesh_changed
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

func set_mod_extra_energy(v:bool):
	mod_extra_energy = v; emit_signal("mods_changed")
func set_mod_no_regen(v:bool):
	mod_no_regen = v; emit_signal("mods_changed")
func set_mod_speed_level(v:int):
	mod_speed_level = v; emit_signal("mods_changed"); emit_signal("speed_mod_changed")
func set_mod_nofail(v:bool):
	mod_nofail = v; emit_signal("mods_changed")
func set_mod_mirror_x(v:bool):
	mod_mirror_x = v; emit_signal("mods_changed")
func set_mod_mirror_y(v:bool):
	mod_mirror_y = v; emit_signal("mods_changed")
func set_mod_nearsighted(v:bool):
	mod_nearsighted = v; emit_signal("mods_changed")
func set_mod_ghost(v:bool):
	mod_ghost = v; emit_signal("mods_changed")

# Registries
var registry_colorset:Registry
var registry_song:Registry
var registry_world:Registry
var registry_mesh:Registry

# Content management
var user_pack_dir:String = "user://packs"
var user_mod_dir:String = "user://mods"
var user_vmap_dir:String = "user://vmaps"
var user_map_dir:String = "user://maps"
var installed_dlc:Array = ["ssp_basegame"]
var installed_mods:Array = []
var installed_packs:Array = []

# User settings
var play_hit_snd:bool = true
var play_miss_snd:bool = true
var approach_rate:float = 50
var sensitivity:float = 1
var parallax:float = 1
var camera_mode:int = Globals.CAMERA_HALF_LOCK
var hitwindow_ms:float = 55
var auto_preview_song:bool = true
var cam_unlock:bool = false
var show_config:bool = true
var enable_grid:bool = true
var enable_border:bool = true
var cursor_scale:float = 1
var edge_drift:float = 0
var enable_drift_cursor:bool = true
var cursor_spin:float = 0
var note_hitbox_size:float = 1.27
var spawn_distance:float = 100
var custom_speed:float = 1
var note_spawn_effect:bool = true
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


# Other save data
var personal_bests:Dictionary = {
#	ss_archive_SAO_CF = [
#		{
#			has_passed = false,
#			mod_extra_energy = false,
#			mod_no_regen = false,
#			mod_speed_level = Globals.SPEED_NORMAL,
#			position = 53000,
#			length = 240000,
#			hit_notes = 4,
#			total_notes = 10
#		}
#	]
}
var favorite_songs:Array = []

var do_archive_convert:bool = false

func save_favorites():
	var file:File = File.new()
	file.open("user://favorites.txt",File.WRITE)
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
	var file:File = File.new()
	file.open("user://pb.json",File.WRITE)
	var json = JSON.print(personal_bests)
	file.store_line(json)
#	file.store_16(4)
#	for songid in personal_bests.keys():
#		file.store_16(65535) # indicate gap between songs
#		file.store_line(songid)
#		for pb in personal_bests[songid]:
#			file.store_16(69) # indicate gap between modifier sets
#			file.store_8(int(pb.has_passed))
#			file.store_8(int(pb.mod_extra_energy))
#			file.store_8(int(pb.mod_no_regen))
#			file.store_8(int(pb.mod_speed_level))
#			file.store_64(int(pb.position))
#			file.store_64(int(pb.length))
#			file.store_32(int(pb.hit_notes))
#			file.store_32(int(pb.total_notes))
#			file.store_16(int(pb.pauses))
##	file.store_16(16384) # indicate eof
	file.close()

func load_pbs():
	var file:File = File.new()
	if file.file_exists("user://pb.json"):
		file.open("user://pb.json",File.READ)
		personal_bests = parse_json(file.get_as_text())
		file.close()
	elif file.file_exists("user://pb"):
		file.open("user://pb",File.READ)
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

func set_pb(songid:String,pbtype:int):
	var pb = personal_bests[songid][pbtype]
	pb.position = song_end_position
	pb.length = song_end_length
	pb.hit_notes = song_end_hits
	pb.total_notes = song_end_total_notes
	pb.pauses = song_end_pause_count
	pb.has_passed = song_end_type == Globals.END_PASS
	save_pbs()

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
	if mod_nofail or mod_mirror_x or mod_mirror_y: return false
	if hitwindow_ms >= 80 or hitwindow_ms <= 0: return false
	var has_passed:bool = song_end_type == Globals.END_PASS
	if personal_bests.has(selected_song.id):
		var pbs:Array = personal_bests[selected_song.id]
		for i in range(pbs.size()):
			var b = pbs[i]
			if (
				b.mod_extra_energy == mod_extra_energy and
				b.mod_no_regen == mod_no_regen and
				b.mod_speed_level == mod_speed_level
			):
				if has_passed:
					if not b.has_passed:
						set_pb(selected_song.id,i)
						return true
					elif song_end_hits > b.hit_notes:
						set_pb(selected_song.id,i)
						return true
					else: return false
				elif song_end_position > b.position and not b.has_passed:
					set_pb(selected_song.id,i)
					return true
				else: return false
		prepare_new_pb(selected_song.id)
		return true
	prepare_new_pb(selected_song.id)
	return true

func get_best():
	if personal_bests.has(selected_song.id):
		var pbs:Array = personal_bests[selected_song.id]
		for b in pbs:
			if (
				b.mod_extra_energy == mod_extra_energy and
				b.mod_no_regen == mod_no_regen and
				b.mod_speed_level == mod_speed_level
			):
				return b

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

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

const current_sf_version = 19

func load_saved_settings():
	var file:File = File.new()
	if file.file_exists("user://settings"):
		var err = file.open("user://settings",File.READ)
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
		if sv >= 18: note_hitbox_size = file.get_float()
		file.close()
	return 0

func save_settings():
	var file:File = File.new()
	file.open("user://settings",File.WRITE)
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
	file.close()

func get_stream_with_default(path:String,default:AudioStream) -> AudioStream:
	var file:File = File.new()
	if file.file_exists(path + ".ogg"): path += ".ogg"
	elif file.file_exists(path + ".mp3"): path += ".mp3"
	elif file.file_exists(path + ".wav"): path += ".wav"
	if file.file_exists(path):
		if !path.begins_with("res://"):
			var stream = Globals.audioLoader.load_file(path)
			if stream and stream is AudioStream: return stream
			else: return default
		else: 
			var mf:AudioStream = load(path) as AudioStream
			if mf is AudioStreamOGGVorbis or mf is AudioStreamMP3: mf.loop = false
			elif mf is AudioStreamSample: mf.loop_mode = AudioStreamSample.LOOP_DISABLED
			return mf
	else: return default

var first_init_done = false
var normal_pb_sound
var fail_asp:AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	fail_asp.volume_db = -10
	call_deferred("add_child",fail_asp)
	pause_mode = PAUSE_MODE_PROCESS

func do_init(_ud=null):
	installed_packs = []
	var lmid
	yield(get_tree().create_timer(0.05),"timeout") # haha thread safety go brrrr
	if first_init_done and selected_song: lmid = selected_song.id
	var lp:bool = false # load pause
	var file:File = File.new()
	var dir:Directory = Directory.new()
	dir.open("user://")
#	var pause_len:float = 0.05
	
	# Setup mod directories if they don't already exist
	if !first_init_done:
		emit_signal("init_stage_reached","Init filesystem")
		if lp: yield(get_tree(),"idle_frame")
		if !dir.dir_exists(user_mod_dir): dir.make_dir(user_mod_dir)
		if !dir.dir_exists(user_pack_dir): dir.make_dir(user_pack_dir)
		if !dir.dir_exists(user_vmap_dir): dir.make_dir(user_vmap_dir)
		if !dir.dir_exists(user_map_dir): dir.make_dir(user_map_dir)
	
	# set up registries
	emit_signal("init_stage_reached","Init registries")
	if lp: yield(get_tree(),"idle_frame")
	registry_colorset = Registry.new()
	registry_song = Registry.new()
	registry_world = Registry.new()
	registry_mesh = Registry.new()
	
	# Register built-in colorsets
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
	
	# Register built-in worlds
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
		"ssp_void", "VOID",
		"res://content/worlds/void.tscn", "Chedski",
		"res://content/worlds/covers/void.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_classic", "Beyond",
		"res://content/worlds/classic.tscn", "Chedski",
		"res://content/worlds/covers/classic.png"
	))
	registry_world.add_item(BackgroundWorld.new(
		"ssp_custom", "Custom (info in the discord)",
		"res://content/worlds/custom.tscn", "Someone",
		"res://content/worlds/covers/custom.png"
	))
	
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
	
	if file.file_exists("user://colors.txt"):
		file.open("user://colors.txt",File.READ)
		var ctxt:String = file.get_as_text()
		file.close()
		var split:Array = ctxt.split("\n",false)
		var colarr:Array = []
		for st in split:
			#var st:String = s
			if st.is_valid_html_color():
				colarr.append(Color(st))
		registry_colorset.add_item(ColorSet.new(
			colarr,
			"colorsfile", "colors.txt (1 per line)", "You!"
		))
	else:
		registry_colorset.add_item(ColorSet.new(
			[ Color("#ffffff") ],
			"colorsfile", "colors.txt (1 per line)", "You!"
		))
	
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
	if dir.dir_exists("user://officialmaps"):
		var vmaps_o:Array = []
		emit_signal("init_stage_reached","Register content 4/4\nImport official map archive")
		yield(get_tree(),"idle_frame")
		dir.change_dir("user://officialmaps")
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
			registry_song.add_vulnus_map("user://officialmaps/" + vmaps_o[i])
		dir.list_dir_end()
	
	# Default 
	emit_signal("init_stage_reached","Init default assets")
	yield(get_tree(),"idle_frame")
	
	emit_signal("init_stage_reached","Init default assets 1/6")
	if lp: yield(get_tree(),"idle_frame")
	selected_colorset = registry_colorset.get_item("ssp_everybodyvotes")
	selected_space = registry_world.get_item("ssp_space_tunnel")
	selected_mesh = registry_mesh.get_item("ssp_square")
	
	assert(selected_colorset)
	assert(selected_space)
	assert(selected_mesh)
	
	emit_signal("init_stage_reached","Init default assets 2/6")
	if lp: yield(get_tree(),"idle_frame")
	miss_snd = load("res://content/sfx/miss.wav")
	
	emit_signal("init_stage_reached","Init default assets 3/6")
	if lp: yield(get_tree(),"idle_frame")
	hit_snd = load("res://content/sfx/hit.wav")
	
	emit_signal("init_stage_reached","Init default assets 4/6")
	if lp: yield(get_tree(),"idle_frame")
	fail_snd = load("res://content/sfx/fail.wav")
	
	emit_signal("init_stage_reached","Init default assets 5/6")
	if lp: yield(get_tree(),"idle_frame")
	pb_snd = load("res://content/sfx/new_best.wav")
	normal_pb_sound = pb_snd
	
	emit_signal("init_stage_reached","Init default assets 6/6")
	if lp: yield(get_tree(),"idle_frame")
	menu_bgm = load("res://content/sfx/music/menu_loop.ogg")
	
	# Read settings
	emit_signal("init_stage_reached","Read user settings")
	yield(get_tree(),"idle_frame")
	var result = load_saved_settings()
	print(result)
	if result != 0:
		# errors are returned when settings are invalid
		get_tree().change_scene("res://starterror.tscn")
		return
	print('settings done')
	
	# Get custom sounds
	emit_signal("init_stage_reached","Load custom assets")
	yield(get_tree(),"idle_frame")
	
	emit_signal("init_stage_reached","Load asset replacement 1/5\nmiss")
	if lp: yield(get_tree(),"idle_frame")
	miss_snd = get_stream_with_default("user://miss",miss_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 2/5\nhit")
	if lp: yield(get_tree(),"idle_frame")
	hit_snd = get_stream_with_default("user://hit",hit_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 3/5\nfail")
	if lp: yield(get_tree(),"idle_frame")
	fail_snd = get_stream_with_default("user://fail",fail_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 4/5\nnew_best")
	if lp: yield(get_tree(),"idle_frame")
	pb_snd = get_stream_with_default("user://new_best",pb_snd)
	
	emit_signal("init_stage_reached","Load asset replacement 5/5\nmenu")
	if lp: yield(get_tree(),"idle_frame")
	menu_bgm = get_stream_with_default("user://menu",menu_bgm)
	
	fail_asp.stream = fail_snd
	Globals.error_sound = miss_snd
	
	# Read PB data
	if !first_init_done:
		emit_signal("init_stage_reached","Read personal bests")
		yield(get_tree(),"idle_frame")
		load_pbs()
		emit_signal("init_stage_reached","Read favorite songs")
		yield(get_tree(),"idle_frame")
		if file.file_exists("user://favorites.txt"):
			file.open("user://favorites.txt",File.READ)
			var txt = file.get_as_text()
			file.close()
			favorite_songs = txt.split("\n")
	
#	yield(get_tree().create_timer(60000),"timeout")
	dir.change_dir("res://")
	first_init_done = true
	do_archive_convert = false
	emit_signal("init_stage_reached","Waiting for menu",true)








