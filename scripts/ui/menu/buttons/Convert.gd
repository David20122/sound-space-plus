extends Button

var debounce = false

func _pressed():
	if debounce or !Rhythia.selected_song: return
	debounce = true
	text = Rhythia.selected_song.convert_to_sspm(true)
	disabled = true
	yield(get_tree().create_timer(0.75),"timeout")
	visible = !(
		Rhythia.selected_song.is_broken or
		Rhythia.selected_song.converted or
		Rhythia.selected_song.songType == Globals.MAP_SSPM2 or
		Rhythia.selected_song.songType == Globals.MAP_NET
	)
	if Rhythia.selected_song.songType == Globals.MAP_SSPM:
		text = "Upgrade map to SSPM v2"
	else:
		text = "Convert map to .sspm"
	debounce = false
