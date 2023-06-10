extends Button

var has_been_pressed:bool = false
func _pressed():
	if has_been_pressed: return
	has_been_pressed = true
	get_parent().black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	SSP.conmgr_transit = null
	get_tree().change_scene("res://menuload.tscn")
