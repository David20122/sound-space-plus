extends CheckBox

func _pressed(): if pressed != SSP.lock_mouse: SSP.lock_mouse = pressed
func _ready(): pressed = SSP.lock_mouse
