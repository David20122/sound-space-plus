extends Button

var has_been_pressed:bool = false
func _pressed():
	if !SSP.selected_song: return
	if has_been_pressed: return
	has_been_pressed = true
	get_parent().get_parent().black_fade_target = true
	yield(get_tree().create_timer(1),"timeout")
	get_tree().change_scene("res://songload.tscn")
