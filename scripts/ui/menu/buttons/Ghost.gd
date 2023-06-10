extends CheckBox

func _process(_d):
	if pressed != SSP.mod_ghost:
		SSP.mod_ghost = pressed

func upd(): pressed = SSP.mod_ghost

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
