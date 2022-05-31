extends CheckBox

func _process(_d):
	if pressed != SSP.mod_mirror_x:
		SSP.mod_mirror_x = pressed

func upd(): pressed = SSP.mod_mirror_x

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
