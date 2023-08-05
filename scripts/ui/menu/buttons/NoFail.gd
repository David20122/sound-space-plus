extends CheckBox

func _process(_d):
	if pressed != Rhythia.mod_nofail:
		Rhythia.mod_nofail = pressed

func upd(): pressed = Rhythia.mod_nofail

func _ready():
	upd()
	Rhythia.connect("mods_changed",self,"upd")
