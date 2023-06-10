extends CheckBox

func _pressed(): if pressed != SSP.enable_border: SSP.enable_border = pressed
func _ready(): pressed = SSP.enable_border
