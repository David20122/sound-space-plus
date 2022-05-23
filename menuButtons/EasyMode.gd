extends CheckBox

func _process(_d):
	if pressed != SSP.mod_extra_energy:
		SSP.mod_extra_energy = pressed

func _ready():
	pressed = SSP.mod_extra_energy
