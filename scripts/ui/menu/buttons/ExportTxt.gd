extends Button

var debounce = false

func _pressed():
	if debounce or !Rhythia.selected_song: return
	debounce = true
	text = "Saving"
	$SaveFile.set_initial_path("~/Downloads/%s.txt" % Rhythia.selected_song.id)
	$SaveFile.show()
	var path = yield($SaveFile,"file_selected")
	disabled = true
	Rhythia.selected_song.export_text(path)
	text = "Export map data"
	disabled = false
	debounce = false

