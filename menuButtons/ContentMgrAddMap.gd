extends Button

var has_been_pressed:bool = false
func _pressed():
	if has_been_pressed: return
	has_been_pressed = true
	get_parent().black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	SSP.conmgr_transit = "addsongs"
	get_tree().change_scene("res://contentmgrload.tscn")

func _ready():
	visible = ProjectSettings.get_setting("application/config/enable_new_content_mgr")
