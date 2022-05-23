extends CheckBox

func _pressed(): if pressed != SSP.show_config: SSP.show_config = pressed
func _ready(): pressed = SSP.show_config
