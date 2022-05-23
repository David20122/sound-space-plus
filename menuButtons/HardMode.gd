extends CheckBox

func _process(_d):
	if pressed != SSP.mod_no_regen:
		SSP.mod_no_regen = pressed

func _ready():
	pressed = SSP.mod_no_regen
