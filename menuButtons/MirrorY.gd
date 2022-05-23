extends CheckBox

func _process(_d):
	if pressed != SSP.mod_mirror_y:
		SSP.mod_mirror_y = pressed

func _ready():
	pressed = SSP.mod_mirror_y
