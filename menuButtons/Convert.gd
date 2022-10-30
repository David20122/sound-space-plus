extends Button

var debounce = false

func _pressed():
	if debounce or !SSP.selected_song: return
	debounce = true
	text = SSP.selected_song.convert_to_sspm(true)
	disabled = true
	yield(get_tree().create_timer(0.75),"timeout")
	visible = !(
		SSP.selected_song.is_broken or
		SSP.selected_song.converted or
		SSP.selected_song.songType == Globals.MAP_SSPM2 or
		SSP.selected_song.songType == Globals.MAP_NET
	)
	if SSP.selected_song.songType == Globals.MAP_SSPM:
		text = "Upgrade map to SSPM v2"
	else:
		text = "Convert map to .sspm"
	debounce = false
