extends Node

@onready var playlists:Registry = preload("res://assets/content/Playlists.tres")
@onready var mapsets:Registry = preload("res://assets/content/Mapsets.tres")
@onready var blocks:Registry = preload("res://assets/content/Blocks.tres")

# VR Vars
@onready var vr_allowed:bool = ProjectSettings.get_setting_with_override("xr/openxr/enabled")
var vr_enabled:bool = false
var vr_interface:XRInterface

func _ready():
	connect("on_init_complete",Callable(self,"_on_init_complete"))

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
	call_deferred("emit_signal","on_init_stage","Import content (1/1)",[
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
func load_game_scene(game_type:int,mapset:Mapset,map_index:int=0):
	var reader = MapsetReader.new()
	var full_mapset = reader.read_from_file(mapset.path,true,map_index)
	reader.call_deferred("free")
	assert(full_mapset.id == mapset.id)
	var packed_scene:PackedScene = load(GameSceneTypes.get(game_type,"res://scenes/Solo.tscn"))
	var scene:GameScene = packed_scene.instantiate() as GameScene
	scene.mapset = full_mapset
	scene.map_index = map_index
	return scene

func _exit_tree():
	if _thread != null: _thread.wait_to_finish()
