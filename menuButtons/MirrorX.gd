extends CheckBox

func _process(_d):
	if pressed != SSP.mod_mirror_x:
		SSP.mod_mirror_x = pressed

func _ready():
	pressed = SSP.mod_mirror_x
