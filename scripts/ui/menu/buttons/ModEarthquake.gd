extends CheckBox

func _process(_d):
	if pressed != SSP.mod_earthquake:
		SSP.mod_earthquake = pressed

func upd(): pressed = SSP.mod_earthquake

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
