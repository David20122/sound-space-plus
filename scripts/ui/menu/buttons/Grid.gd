extends CheckBox

func _pressed(): if pressed != SSP.enable_grid: SSP.enable_grid = pressed
func _ready(): pressed = SSP.enable_grid
