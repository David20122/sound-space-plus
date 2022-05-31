extends CheckBox

func _process(_d):
	if pressed != SSP.mod_nofail:
		SSP.mod_nofail = pressed

func upd(): pressed = SSP.mod_nofail

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
