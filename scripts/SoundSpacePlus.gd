extends Node

@onready var selected_mods:Mods = Mods.new()

@onready var playlists:Registry = load("res://assets/content/Playlists.tres")
@onready var mapsets:Registry = load("res://assets/content/Mapsets.tres")
@onready var blocks:Registry = load("res://assets/content/Blocks.tres")
@onready var worlds:Registry = load("res://assets/content/Worlds.tres")

var settings_path = "user://preferences.json"
var settings:Settings
var first_time:bool = false

func _ready():
	connect("on_init_complete",Callable(self,"_on_init_complete"))

	var exec_settings = OS.get_executable_path().get_base_dir().path_join("preferences.json")
	if FileAccess.file_exists(exec_settings): settings_path = exec_settings
	call_deferred("load_settings")

# Settings
func load_settings():
	var load_settings_path = settings_path
	var data = {}
	if FileAccess.file_exists(ProjectSettings.globalize_path(load_settings_path)):
		var file = FileAccess.open(load_settings_path,FileAccess.READ)
		data = JSON.parse_string(file.get_as_text())
	settings = Settings.new(data)
	first_time = settings.first_time
func save_settings():
	var file = FileAccess.open(settings_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(settings.data,"",false))

# Init
var _initialised:bool = false
var _thread:Thread
var is_init:bool = true
var loading:bool = false
var warning_seen:bool = false
signal on_init_start
signal on_init_stage
signal on_init_complete

func _on_init_complete():
	is_init = false
	loading = false
func init():
	assert(!loading) #,"Already loading")
	loading = true
	if !_initialised:
		_initialised = true
		_thread = _exec_initialiser("_do_init")
		return
	_thread = _exec_initialiser("_reload")
func _exec_initialiser(initialiser:String):
	var thread = Thread.new()
	var err = thread.start(Callable(self,initialiser),Thread.PRIORITY_HIGH)
	assert(err == OK) #,"Thread failed")
	call_deferred("emit_signal","on_init_start",initialiser)
	return thread
func _load_mapsets(reset:bool=false):
	if reset: mapsets.clear()
	var song_reader = MapsetReader.new()
	var map_files = []
	if !DirAccess.dir_exists_absolute(Globals.Folders.get("maps")):
		DirAccess.make_dir_recursive_absolute(Globals.Folders.get("maps"))
	var maps_dir = DirAccess.open(Globals.Folders.get("maps"))
	maps_dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var paths = mapsets.items.map(func(mapset):
		if mapset.broken: return "null"
		return mapset.path
	)
	var new_paths = []
	var file_name = maps_dir.get_next()
	while file_name != "":
		var path = Globals.Folders.get("maps").path_join(file_name)
		new_paths.append(path)
		if not path in paths: map_files.append(path)
		file_name = maps_dir.get_next()
	if !reset:
		call_deferred("emit_signal","on_init_stage","Import content (1/2)",[
			{text="Remove missing maps",max=1,value=1}
		])
		for path in paths:
			if path == "null" or path in new_paths:
				continue
			mapsets.remove_item(mapsets.items[paths.find(path)])
	var map_count = map_files.size()
	call_deferred("emit_signal","on_init_stage","Import content (1/2)",[
		{text="Import maps (0/%s)" % map_count,max=map_count,value=0}
	])
	var map_idx = 0
	for map_file in map_files:
		map_idx += 1
		var song = song_reader.read_from_file(map_file)
		call_deferred("emit_signal","on_init_stage",null,[
			{text="Import maps (%s/%s)" % [map_idx,map_count],value=map_idx,max=map_count},
			{text=song.name,max=1,value=1}
		])
		mapsets.add_item(song)
	call_deferred("emit_signal","on_init_stage",null,[{text="Free MapsetReader",max=map_count,value=map_idx}])
	song_reader.call_deferred("free")
func _load_playlists(reset:bool=false):
	if reset: playlists.clear()
	var list_reader = PlaylistReader.new()
	var list_files = []
	if !DirAccess.dir_exists_absolute(Globals.Folders.get("playlists")):
		DirAccess.make_dir_recursive_absolute(Globals.Folders.get("playlists"))
	var lists_dir = DirAccess.open(Globals.Folders.get("playlists"))
	lists_dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var list_name = lists_dir.get_next()
	while list_name != "":
		list_files.append(Globals.Folders.get("playlists").path_join(list_name))
		list_name = lists_dir.get_next()
	var list_count = list_files.size()
	call_deferred("emit_signal","on_init_stage","Import content (2/2)",[
		{text="Import playlists (0/%s)" % list_count,max=list_count,value=0}
	])
	var list_idx = 0
	for list_file in list_files:
		list_idx += 1
		var list = list_reader.read_from_file(list_file)
		call_deferred("emit_signal","on_init_stage",null,[
			{text="Import playlists (%s/%s)" % [list_idx,list_count],value=list_idx,max=list_count}
		])
		list.load_mapsets()
		playlists.add_item(list)
	call_deferred("emit_signal","on_init_stage",null,[{text="Free PlaylistReader",max=list_count,value=list_idx}])
	list_reader.call_deferred("free")
func _do_init():
	call_deferred("emit_signal","on_init_stage","Waiting")
	_load_mapsets(true)
	_load_playlists(true)
	call_deferred("emit_signal","on_init_stage","Update folders")
	Globals.call_deferred("update_folders")
	call_deferred("emit_signal","on_init_complete")
func _reload():
	call_deferred("emit_signal","on_init_stage","Reloading content")
	_load_mapsets(false)
	_load_playlists(false)
	call_deferred("emit_signal","on_init_complete")

# Game Scene
enum GameType {
	SOLO,
	MULTI
}
var game_scene:Node
func load_game_scene(game_type:int,mapset:Mapset,map_index:int=0):
	var reader = MapsetReader.new()
	var full_mapset = reader.read_from_file(mapset.path,true,map_index)
	reader.call_deferred("free")
	assert(full_mapset.id == mapset.id)
	var scene
	match game_type:
		GameType.SOLO:
			var packed_scene:PackedScene = preload("res://scenes/Solo.tscn")
			scene = packed_scene.instantiate()
			scene.mods = selected_mods
			scene.settings = settings
			scene.mapset = full_mapset
			scene.map_index = map_index
		GameType.MULTI:
			var packed_scene:PackedScene = preload("res://scenes/Multi.tscn")
			scene = packed_scene.instantiate()
			scene.mods = Multiplayer.lobby.mods
			scene.mapset = full_mapset
			scene.map_index = map_index
	game_scene = scene
	return scene

func _exit_tree():
	if _thread != null: _thread.wait_to_finish()
