extends CheckBox

func _process(_d):
	if pressed != SSP.mod_nofail:
		SSP.mod_nofail = pressed

func _ready():
	pressed = SSP.mod_nofail
