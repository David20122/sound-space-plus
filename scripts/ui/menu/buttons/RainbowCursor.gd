extends CheckBox

func _pressed(): if pressed != SSP.rainbow_cursor: SSP.rainbow_cursor = pressed
func _ready(): pressed = SSP.rainbow_cursor
