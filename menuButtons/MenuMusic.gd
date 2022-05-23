extends CheckBox

func _pressed(): if pressed != SSP.play_menu_music: SSP.play_menu_music = pressed
func _ready(): pressed = SSP.play_menu_music
