extends CheckBox

func _pressed(): if pressed != SSP.cursor_trail: SSP.cursor_trail = pressed
func _ready(): pressed = SSP.cursor_trail
