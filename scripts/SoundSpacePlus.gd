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
	OS.min_window_size = Vector2(640,480)
	OS.center_window()
	connect("on_init_complete",self,"_on_init_complete")

func _on_init_complete():
	_thread.wait_to_finish()
	_thread.queue_free()
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
	return thread
func _do_init():
	emit_signal("on_init_complete")
func _reload():
	emit_signal("on_init_complete")