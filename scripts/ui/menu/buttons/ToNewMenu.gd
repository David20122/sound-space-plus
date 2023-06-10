extends Button

var has_been_pressed:bool = false
func _pressed():
	if has_been_pressed: return
	has_been_pressed = true
	get_parent().black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	SSP.menu_target = "res://menu2.tscn"
	get_tree().change_scene("res://menuload.tscn")

func _ready():
	if !ProjectSettings.get_setting("application/config/enable_new_content_mgr"):
		margin_right += 99
		margin_left += 99
