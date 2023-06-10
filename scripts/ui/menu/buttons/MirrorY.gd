extends CheckBox

func _process(_d):
	if pressed != SSP.mod_mirror_y:
		SSP.mod_mirror_y = pressed

func upd(): pressed = SSP.mod_mirror_y

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
