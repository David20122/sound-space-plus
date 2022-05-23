extends CheckBox

func _pressed(): if pressed != SSP.enable_drift_cursor: SSP.enable_drift_cursor = pressed
func _ready(): pressed = SSP.enable_drift_cursor
