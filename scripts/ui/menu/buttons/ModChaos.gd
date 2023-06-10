extends CheckBox

func _process(_d):
	if pressed != SSP.mod_chaos:
		SSP.mod_chaos = pressed

func upd(): pressed = SSP.mod_chaos

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
