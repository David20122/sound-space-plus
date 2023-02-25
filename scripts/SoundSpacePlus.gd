extends Node

@onready var playlists:Registry = load("res://assets/content/Playlists.tres")
@onready var mapsets:Registry = load("res://assets/content/Mapsets.tres")
@onready var blocks:Registry = load("res://assets/content/Blocks.tres")
@onready var worlds:Registry = load("res://assets/content/Worlds.tres")

var favourites:Array[String] = []
func load_favourites():
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://favorites.txt")):
		var favorites = FileAccess.open("user://favorites.txt",FileAccess.READ)
		var line = favorites.get_line()
		while line != "":
			favourites.append(line)
			line = favorites.get_line()
func save_favourites():
	var favorites = FileAccess.open("user://favorites.txt",FileAccess.WRITE)
	for line in favourites:
		favorites.store_line(line)

var settings_path = "user://preferences.json"
var settings:Settings
var first_time:bool = false

func _ready():
	load_settings()
	connect("on_init_complete",Callable(self,"_on_init_complete"))

# Settings
func load_settings():
	var exec_settings = OS.get_executable_path().path_join("preferences.json")
	if FileAccess.file_exists(exec_settings):
		settings_path = exec_settings
	var data = {}
	if FileAccess.file_exists(ProjectSettings.globalize_path(settings_path)):
		var file = FileAccess.open(settings_path,FileAccess.READ)
		data = JSON.parse_string(file.get_as_text())
	settings = Settings.new(data)
	first_time = settings.first_time
func save_settings():
	var file = FileAccess.open(settings_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(settings.data,"",false))
	
func _physics_process(delta):
	var volume = settings.volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),linear_to_db(volume.master))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Menu"),linear_to_db(volume.master_menu))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Menu Music"),linear_to_db(volume.menu_music))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Menu SFX"),linear_to_db(volume.menu_sfx))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Game"),linear_to_db(volume.master_game))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Game Music"),linear_to_db(volume.game_music))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Game SFX"),linear_to_db(volume.game_sfx))

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
func _load_content(full_reload=false):
	# Import maps
	if full_reload: mapsets.clear()
	var song_reader = MapsetReader.new()
	var map_files = []
	if !DirAccess.dir_exists_absolute(Globals.Folders.get("maps")):
		DirAccess.make_dir_recursive_absolute(Globals.Folders.get("maps"))
	var maps_dir = DirAccess.open(Globals.Folders.get("maps"))
	maps_dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file_name = maps_dir.get_next()
	while file_name != "":
		map_files.append(Globals.Folders.get("maps").path_join(file_name))
		file_name = maps_dir.get_next()
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
	call_deferred("emit_signal","on_init_stage",null,[{text="Load favorites",max=map_count,value=map_idx}])
	load_favourites()
	# Import playlists
	if full_reload: playlists.clear()
	var list_reader = PlaylistReader.new()
	var list_files = []
	if !DirAccess.dir_exists_absolute(Globals.Folders.get("playlists")):
		DirAccess.make_dir_recursive_absolute(Globals.Folders.get("playlists"))
	var lists_dir = DirAccess.open(Globals.Folders.get("playlists"))
	maps_dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var list_name = lists_dir.get_next()
	while list_name != "":
		list_files.append(Globals.Folders.get("playlists").path_join(file_name))
		list_name = maps_dir.get_next()
	var list_count = map_files.size()
	call_deferred("emit_signal","on_init_stage","Import content (2/2)",[
		{text="Import playlists (0/%s)" % list_count,max=list_count,value=0}
	])
	var list_idx = 0
	for list_file in list_files:
		list_idx += 1
		var list = list_reader.read_from_file(list_file)
		call_deferred("emit_signal","on_init_stage",null,[
			{text="Import lists (%s/%s)" % [map_idx,map_count],value=map_idx,max=map_count}
		])
		list.load_mapsets()
		playlists.add_item(list)
	call_deferred("emit_signal","on_init_stage",null,[{text="Free PlaylistReader",max=map_count,value=map_idx}])
	list_reader.call_deferred("free")
func _do_init():
	call_deferred("emit_signal","on_init_stage","Waiting")
	_load_content(true)
	call_deferred("emit_signal","on_init_stage","Update folders")
	Globals.call_deferred("update_folders")
	call_deferred("emit_signal","on_init_complete")
func _reload():
	call_deferred("emit_signal","on_init_stage","Reloading content")
	_load_content(false)
	call_deferred("emit_signal","on_init_complete")

# Game Scene
enum GameType {
	SOLO,
	MULTI
}
const GameSceneTypes = {
	GameType.SOLO: "res://scenes/Solo.tscn"
}
var game_scene:GameScene
func load_game_scene(game_type:int,mapset:Mapset,map_index:int=0):
	var reader = MapsetReader.new()
	var full_mapset = reader.read_from_file(mapset.path,true,map_index)
	reader.call_deferred("free")
	assert(full_mapset.id == mapset.id)
	var packed_scene:PackedScene = load(GameSceneTypes.get(game_type,"res://scenes/Solo.tscn"))
	var scene:GameScene = packed_scene.instantiate() as GameScene
	scene.settings = settings
	scene.mapset = full_mapset
	scene.map_index = map_index
	game_scene = scene
	return scene

func _exit_tree():
	if _thread != null: _thread.wait_to_finish()
