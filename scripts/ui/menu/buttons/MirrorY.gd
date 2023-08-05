extends CheckBox

func _process(_d):
	if pressed != Rhythia.mod_mirror_y:
		Rhythia.mod_mirror_y = pressed

func upd(): pressed = Rhythia.mod_mirror_y

func _ready():
	upd()
	Rhythia.connect("mods_changed",self,"upd")
