extends CheckBox

func _process(_d):
	if pressed != Rhythia.mod_earthquake:
		Rhythia.mod_earthquake = pressed

func upd(): pressed = Rhythia.mod_earthquake

func _ready():
	upd()
	Rhythia.connect("mods_changed",self,"upd")
