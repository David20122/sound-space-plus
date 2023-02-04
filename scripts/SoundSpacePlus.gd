extends Node

signal on_init_start
signal on_init_stage
signal on_init_complete

var _initialised:bool = false
var _thread:Thread

var is_init:bool = true
var loading:bool = false
var warning_seen:bool = false

func _ready():
	connect("on_init_complete",self,"_on_init_complete")

func _on_init_complete():
	is_init = false
	loading = false

func init():
	assert(!loading,"Already loading")
	loading = true
	if !_initialised:
		_initialised = true
		_thread = _exec_initialiser("_do_init")
		return
	_thread = _exec_initialiser("_reload")

func _exec_initialiser(initialiser:String):
	var thread = Thread.new()
	var err = thread.start(self,initialiser,null,2)
	assert(err == OK,"Thread failed")
	emit_signal("on_init_start",initialiser)
	return thread

func _load_content():
	# Import maps
	var maps_start = Time.get_ticks_usec()
	var temp_maps = []
	var song_reader = SongReader.new()
	var map_files = []
	var maps_dir = Directory.new()
	if !maps_dir.dir_exists(Globals.Folders.get("maps")):
		maps_dir.make_dir(Globals.Folders.get("maps"))
	maps_dir.open(Globals.Folders.get("maps"))
	maps_dir.list_dir_begin(true,true)
	var file_name = maps_dir.get_next()
	while file_name != "":
		map_files.append(Globals.Folders.get("maps").plus_file(file_name))
		file_name = maps_dir.get_next()
	var map_count = map_files.size()
	emit_signal("on_init_stage","Import content (1/1)",[{text="Import maps (0/%s)" % map_count,max=map_count,value=0}])
	var map_idx = 1
	for map_file in map_files:
		emit_signal("on_init_stage",null,
		[{text="Import maps (%s/%s)" % [map_idx,map_count],value=map_idx,max=map_count}])
		temp_maps.append(song_reader.read_from_file(map_file))
		map_idx += 1
	var maps_took = Time.get_ticks_usec()-maps_start
	print("Took %s usecs" % maps_took)
	emit_signal("on_init_stage",null,[{text="Queue free SongReader" % [map_idx,map_count],max=map_count,value=map_idx}])
	song_reader.queue_free()

func _do_init():
	emit_signal("on_init_stage","Import content")
	_load_content()
	emit_signal("on_init_complete")
func _reload():
	emit_signal("on_init_stage","Reloading content")
	emit_signal("on_init_complete")

func _exit_tree():
	if _thread != null: _thread.wait_to_finish()