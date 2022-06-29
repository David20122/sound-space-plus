extends Button

var debounce = false

func _pressed():
	if debounce or !SSP.selected_song: return
	debounce = true
	text = "Saving"
	$SaveFile.set_initial_path("~/Downloads/%s.txt" % SSP.selected_song.id)
	$SaveFile.show()
	var path = yield($SaveFile,"file_selected")
	disabled = true
	SSP.selected_song.export_text(path)
	text = "Export map data"
	disabled = false
	debounce = false

