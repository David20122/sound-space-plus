extends CheckBox

func _process(_d):
	if pressed != SSP.mod_extra_energy:
		SSP.mod_extra_energy = pressed

func upd(): pressed = SSP.mod_extra_energy

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
