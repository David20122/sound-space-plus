extends Button

export(String,FILE,"*.tscn") var target_scene

var has_been_pressed:bool = false
func _pressed():
	var runBtn = get_node("/root/Menu/MapSelect/Run")
	if has_been_pressed or runBtn.has_been_pressed: return
	runBtn.has_been_pressed = true
	has_been_pressed = true
	get_node("/root/Menu").black_fade_target = true
	yield(get_tree().create_timer(1),"timeout")
	get_tree().change_scene(target_scene)
