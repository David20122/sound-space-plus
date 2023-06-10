extends CheckBox

func _process(_d):
	if pressed != SSP.mod_no_regen:
		SSP.mod_no_regen = pressed

func upd(): pressed = SSP.mod_no_regen

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
