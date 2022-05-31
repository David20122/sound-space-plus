extends CheckBox

func _process(_d):
	if pressed != SSP.mod_nearsighted:
		SSP.mod_nearsighted = pressed

func upd(): pressed = SSP.mod_nearsighted

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
