extends CheckBox

func _pressed(): if pressed != SSP.auto_preview_song: SSP.auto_preview_song = pressed
func _ready(): pressed = SSP.auto_preview_song
