extends CheckBox

func _pressed(): if pressed != SSP.cam_unlock: SSP.cam_unlock = pressed
func _ready(): pressed = SSP.cam_unlock
