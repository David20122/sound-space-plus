extends Button

var has_been_pressed:bool = false

func files_dropped(files:PoolStringArray,_screen:int):
	if has_been_pressed: return
	if files[0].get_extension() == "sspre":
		has_been_pressed = true
		SSP.replay = Replay.new()
		SSP.replaying = true
		SSP.replay_path = files[0]
		get_viewport().get_node("Menu").black_fade_target = true
		yield(get_tree().create_timer(0.35),"timeout")
		get_tree().change_scene("res://songload.tscn")

func _pressed():
	# button functionality
	if !SSP.selected_song: return
	if has_been_pressed: return
	has_been_pressed = true
	get_viewport().get_node("Menu").black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	get_tree().change_scene("res://songload.tscn")

func _ready():
	get_tree().connect("files_dropped",self,"files_dropped")
